require 'openssl'
require 'digest/sha1'

module Tools::Babel
  def self.bytes_to(size, options={})
    options.reverse_merge!(:unit => nil, :show_unit => true)

    unit = options[:unit]

    divider = 1

    unless options[:unit]
      if size < 1000
        unit = :b
      elsif size < 1000000
        unit = :kb
      elsif size < 1000000000
        unit = :mb
      else
        unit = :gb
      end
    end

    case unit
      when :kb then divider = 1000
      when :mb then divider = 1000000
      when :gb then divider = 1000000000
    end

    return sprintf("%0.02f", (size.to_f / divider)) + (options[:show_unit] ? ' ' + unit.to_s.upcase_utf8 : '')
  end

  def self.decrypt(value, password)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = Digest::SHA1.hexdigest(password)
    d = c.update(Base64.decode64(value))
    begin
      d << c.final
    rescue
      return nil
    end

    return d
  end

  def self.encrypt(value, password)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = Digest::SHA1.hexdigest(password)
    e = c.update(value)
    e << c.final

    return Base64.encode64(e).strip
  end

  def self.enumerate(terms)
	  last_element = terms.pop;

    if terms.length == 0
      return last_element;
    else
      return terms.join(', ') + ' ' + I18n.t('and') + ' ' + last_element;
    end
  end

	def self.extract_first_quotes(value)
	  if value.index('"')
	    return value.split('"')[1]
	  else
	    return ''
	  end
  end

	def self.extract_first_tag(value)
	  if value.index('<') and value.index('>')
	    return value[value.index('<') + 2, value.rindex('>') - value.index('<')-2]
	  else
	    return ''
	  end
  end

  def self.from_strange_encoding(value)
    char_table = {'003' => "'", '021' => '-', '023' => '-', '030' => "'", '031' => "'", '034' => '"', '035' => '"'}

    value_decoded = []

    value.each_char { |c| value_decoded << (c.inspect.length == 6 ? char_table[c.inspect[2,3]].to_s : c) }

    return value_decoded.join
  end

  def self.get_latin_table(invert=false)
    table = {'Æ' => '306', 'Á' => '301', 'Â' => '302', 'Ä' => '304', 'À' => '300', 'Å' => '305', 'Ã' => '303', 'Ç' => '307', 'É' => '311', 'Ê' => '312', 'Ë' => '313', 'È' => '310', 'Ð' => '320', '€' => '240', 'Í' => '315', 'Î' => '316', 'Ï' => '317', 'Ì' => '314', 'Ł' => '225', 'Ñ' => '321', 'Œ' => '226', 'Ó' => '323', 'Ô' => '324', 'Ö' => '326', 'Ò' => '322', 'Ø' => '330', 'Õ' => '325', 'Š' => '227', 'Þ' => '336', 'Ú' => '332', 'Û' => '333', 'Ü' => '334', 'Ù' => '331', 'Ý' => '335', 'Ÿ' => '230', 'Ž' => '231', 'á' => '341', 'â' => '342', '´' => '264', 'ä' => '344', 'æ' => '346', 'à' => '340', 'å' => '345', '^' => '136', '~' => '176', '*' => '052', 'ã' => '343', '˘' => '030', '¦' => '246', '•' => '200', 'ˇ' => '031', 'ç' => '347', '¸' => '270', '¢' => '242', 'ˆ' => '032', '©' => '251', '¤' => '244', '†' => '201', '‡' => '202', '°' => '260', '÷' => '367', 'ı' => '232', 'é' => '351', 'ê' => '352', 'ë' => '353', 'è' => '350', 'ð' => '360', '¡' => '241', 'ﬁ' => '223', 'ﬂ' => '224', 'ƒ' => '206', 'ß' => '337', '«' => '253', '»' => '273', 'í' => '355', 'î' => '356', 'ï' => '357', 'ì' => '354', 'ł' => '233', 'µ' => '265', '×' => '327', 'ñ' => '361', '#' => '043', 'ó' => '363', 'ô' => '364', 'ö' => '366', 'œ' => '234', 'ò' => '362', 'ª' => '252', 'º' => '272', 'ø' => '370', 'õ' => '365', '¶' => '266', '¿' => '277', '„' => '214', '“' => '215', '”' => '216', '®' => '256', 'š' => '235', '§' => '247', '£' => '243', 'þ' => '376', '™' => '222', 'ú' => '372', 'û' => '373', 'ü' => '374', 'ù' => '371', 'ý' => '375', 'ÿ' => '377', '¥' => '245', 'ž' => '236'}
    table = table.invert if invert
    return table
  end

  def self.random_string(size)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		content = ""
		1.upto(size) { |i| content << chars[rand(chars.size-1)] }

		return content
  end

  def self.strip_html(value)
    return (value) ? value.to_s.gsub(/<\/?[^>]*>/, "") : value
  end

	def self.to_cost(amount, unit='')
	  cost = sprintf("%0.02f", (amount.to_f / 100)).gsub('.', ',')

	  case unit
      when 'cad', 'usd' then cost += ' $'
      when 'eur' then cost += ' €'
	  end

	  return cost
  end

	def self.to_latin_encoded(value)
    latin_table = self.get_latin_table
    value_encoded = ''

    value.each_char { |c| value_encoded << (latin_table[c] ? "\\" + latin_table[c] : c) }

    return value_encoded
  end

	# TODO : Finish the method
	def self.to_iso3166_1(country_code, options={})
	  options.reverse_merge!(:to_alpha => '3')

	  if options[:to_alpha] == '3'
	    return case country_code.to_s.downcase
        when 'ca' then return 'can'
        when 'us' then return 'usa'
        when 'fr' then return 'fra'
      end
    end

    return nil
  end

	# TODO : Finish the method
	def self.to_iso639_2(language, options={})
	  options.reverse_merge!(:from => '639-1')

	  if options[:from] == '639-1'
	    return case language.to_s.downcase
        when "fre" then "fr"
        when "eng" then "en"
        when "spa" then "sp"
      end
	  end

    return nil
  end

	def self.to_roman(numeric)
    numerals = [
      { :roman => 'M', :arab => 1000 },
      { :roman => 'CM', :arab => 900 },
      { :roman => 'D', :arab => 500 },
      { :roman => 'CD', :arab => 400 },
      { :roman => 'C', :arab => 100 },
      { :roman => 'XC', :arab => 90 },
      { :roman => 'L', :arab => 50 },
      { :roman => 'XL', :arab => 40 },
      { :roman => 'X', :arab => 10 },
      { :roman => 'IX', :arab => 9 },
      { :roman => 'V', :arab => 5 },
      { :roman => 'IV', :arab => 4 },
      { :roman => 'I', :arab => 1 }
    ]
    roman = '';
    numerals.each do |num|
      while numeric >= num[:arab]
        roman += num[:roman]
        numeric -= num[:arab]
      end
    end
    return roman
  end

  # Try to convert the string to utf 8.
  def self.to_utf8(value, from='ISO-8859-1')
    value = Iconv.conv('utf-8', from, value) if not value.to_s.isutf8

		return value
		# If the string is too long it will loop eternaly in a hell hole. Need to be corrected.
    #value_conv = ""
    #value.each_char do |s|
    #  if s[0] == 194
    #    value_conv += "'"
    #  else
    #    value_conv += s
    #  end
    #end
		#return value_conv
	end
end
