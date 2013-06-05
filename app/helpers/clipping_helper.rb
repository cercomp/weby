module ClippingHelper

  def my_truncate(text, size = 100, omission = '...')
    result = ""
    text.split.each do |word|
      break if result.size + word.size + 1 + omission.size > size
      result << "#{word} "
    end
    result + omission
  end
  
end
