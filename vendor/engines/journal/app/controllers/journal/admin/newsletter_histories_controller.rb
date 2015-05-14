module Journal::Admin
  class NewsletterHistoriesController < Journal::ApplicationController
    def index
      @newsletterlist = get_news
    end

    def pdf
      comp = Weby::Components.factory(current_site.components.find_by_name("newsletter"))
      newsletterlist = get_news
      Prawn::Document.generate("public/emails.pdf") do |pdf|
        pdf.text "UNIVERSIDADE FEDERAL DE GOIÁS", size: 16, align: :center, style: :bold
        pdf.text comp.report_logo, align: :left
        pdf.text comp.report_title, size: 16, align: :center
        pdf.text "  ", size: 20
        pdf.text "ENVIO DE NEWSLETTER", size: 14, align: :center, style: :bold
        pdf.text "Período compreendido entre: "+@dt_start.strftime("%d/%m/%Y")+" - "+@dt_end.strftime("%d/%m/%Y"),
            size: 12, align: :center
        table_data = [["<b>"+t(".title")+"</b>","<b>"+t(".user")+"</b>",
                       "<b>"+t(".sent_by")+"</b>","<b>"+t(".date_sent")+"</b>","<b>"+t(".qtty")+"</b>"]]
        newsletterlist.each do |newsletter|
          table_data.insert(table_data.length,
                           [newsletter.news.title,newsletter.news.user.first_name,newsletter.user.first_name,
                           l(newsletter.created_at, format: :short).to_s,newsletter.emails.split(',').count.to_s])
        end
        pdf.table(table_data, width: 550, cell_style: { inline_format: true, size: 10 })
      end
      send_file "public/emails.pdf", type: "application/pdf", x_sendfile: true
    end

    def csv
      comp = Weby::Components.factory(current_site.components.find_by_name("newsletter"))
      newsletterlist = get_news
      File.open("public/dados.csv", 'w') do |arquivo|
        arquivo.puts comp.report_logo
        arquivo.puts "UNIVERSIDADE FEDERAL DE GOIAS"
        arquivo.puts comp.report_title
        arquivo.puts
        arquivo.puts "ENVIO DE NEWSLETTER"
        arquivo.puts "Período compreendido entre: "+@dt_start.strftime("%d/%m/%Y")+" - "+@dt_end.strftime("%d/%m/%Y")
        arquivo.puts t(".title")+","+t(".user")+","+t(".sent_by")+","+t(".date_sent")+","+t(".qtty")
        newsletterlist = get_news
        newsletterlist.each do |newsletter|
          arquivo.puts newsletter.news.title+","+newsletter.news.user.first_name+","+newsletter.user.first_name+","+
                       l(newsletter.created_at, :format => :short).to_s+","+newsletter.emails.split(',').count.to_s
        end
      end
     send_file "public/dados.csv", type: "application/txt", x_sendfile: true
    end

    def get_news
      @dt_start = (params[:dt_start].nil? || params[:dt_start].empty?) ? Date.today-30 : Date.parse(params[:dt_start] + " 00:00:01")
      @dt_end = (params[:dt_end].nil? || params[:dt_end].empty?) ? Date.today.end_of_day : Date.parse(params[:dt_end]).end_of_day
      news = Journal::NewsletterHistories.get_by_date(current_site.id, @dt_start, @dt_end)
    end
  end
end
