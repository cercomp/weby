require 'rails_helper'

describe ActivityRecordsHelper, type: :helper do
  let(:activity_record) do
    build(:activity_record,
          loggeable_type: 'Journal::News',
          differences: { 'date_begin_at' => ['20/11/2026 10:00', '25/11/2026 10:00'] })
  end

  describe '#activity_record_attr_name' do
    it 'translates date_begin_at into friendly name' do
      expect(helper.activity_record_attr_name(activity_record, 'date_begin_at')).to eq('Data de publicação / início')
    end

    it 'translates image/repository_id into Imagem principal' do
      expect(helper.activity_record_attr_name(activity_record, 'repository_id')).to eq('Imagem principal')
    end

    it 'preserves locale suffix if present' do
      expect(helper.activity_record_attr_name(activity_record, 'title (en)')).to eq('Título (en)')
    end
  end

  describe '#format_diff_display' do
    it 'formats empty values gracefully' do
      expect(helper.format_diff_display('title', nil)).to include('(vazio)')
    end

    it 'formats status with label badge' do
      html = helper.format_diff_display('status', 'published')
      expect(html).to include('label-success')
      expect(html).to include('Publicada')
    end

    it 'formats front flag with badge' do
      html = helper.format_diff_display('front', 'Sim')
      expect(html).to include('label-success')
    end
  end

  describe '#activity_differences_summary' do
    it 'renders single difference inline with before and after' do
      html = helper.activity_differences_summary(activity_record)
      expect(html).to include('Data de publicação / início')
      expect(html).to include('20/11/2026 10:00')
      expect(html).to include('25/11/2026 10:00')
    end

    it 'renders multiple differences summary' do
      multi_record = build(:activity_record,
                           loggeable_type: 'Journal::News',
                           differences: {
                             'date_begin_at' => ['20/11/2026 10:00', '25/11/2026 10:00'],
                             'status' => ['draft', 'published']
                           })
      html = helper.activity_differences_summary(multi_record)
      expect(html).to include('Alterações')
      expect(html).to include('Data de publicação / início')
      expect(html).to include('Status de publicação')
    end

    it 'returns nil if record has no differences' do
      empty_record = build(:activity_record, differences: {})
      expect(helper.activity_differences_summary(empty_record)).to be_nil
    end
  end
end
