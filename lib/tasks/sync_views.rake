namespace :weby do
  desc 'Sincroniza os contadores de visualizacoes bufferizados no Redis para o banco PostgreSQL'
  task sync_views: :environment do
    redis = Weby.redis
    unless redis
      puts 'Redis nao configurado. Nada para sincronizar.'
      next
    end

    sync_model_views = lambda do |redis_key, model_class|
      views = redis.hgetall(redis_key)
      next if views.blank?

      synced = 0
      views.each do |id, count|
        val = count.to_i
        next if val <= 0

        # Decrementa no Redis o montante que sera sincronizado
        redis.hincrby(redis_key, id.to_s, -val)
        model_class.where(id: id).update_all("view_count = COALESCE(view_count, 0) + #{val}")
        synced += val
      end

      # Remove do hash entradas zeradas
      redis.hgetall(redis_key).each do |id, count|
        redis.hdel(redis_key, id) if count.to_i <= 0
      end

      puts "Sincronizado #{model_class.name}: #{synced} visualizacoes." if synced > 0
    end

    sync_model_views.call('weby:views:sites', Site)
    sync_model_views.call('weby:views:pages', Page)
    sync_model_views.call('weby:views:albums', Album)
    sync_model_views.call('weby:views:album_photos', AlbumPhoto)
    sync_model_views.call('weby:views:news', Journal::News) if defined?(Journal::News)
    sync_model_views.call('weby:views:events', Calendar::Event) if defined?(Calendar::Event)

    puts 'Sincronizacao de visualizacoes concluida com sucesso.'
  end
end
