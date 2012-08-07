require 'uuidtools'

module Surveyor
  class Common
    RAND_CHARS = [('a'..'z'), ('A'..'Z'), (0..9)].map{|r| r.to_a}.flatten.join
    OPERATORS = %w(== != < > <= >= =~)
    
    class << self
      def make_tiny_code(len = 10)
        if RUBY_VERSION < "1.8.7"
          (1..len).to_a.map{|i| RAND_CHARS[rand(RAND_CHARS.size), 1] }.join
        else
          len.times.map{|i| RAND_CHARS[rand(RAND_CHARS.size), 1] }.join
        end
      end

      def to_normalized_string(text)
        words_to_omit = %w(a be but has have in is it of on or the to when)
        col_text = text.to_s.gsub(/(<[^>]*>)|\n|\t/su, ' ') # Remove html tags
        col_text.downcase!                            # Remove capitalization
        col_text.gsub!(/\"|\'/u, '')                   # Remove potential problem characters
        col_text.gsub!(/\(.*?\)/u,'')                  # Remove text inside parens
        col_text.gsub!(/\W/u, ' ')                     # Remove all other non-word characters      
        cols = (col_text.split(' ') - words_to_omit)
        (cols.size > 5 ? cols[-5..-1] : cols).join("_")
      end
      
      def equal_json_excluding_wildcards(a,b)
        return false if a.nil? or b.nil?
        a = a.is_a?(String) ? JSON.load(a) : JSON.load(a.to_json)
        b = b.is_a?(String) ? JSON.load(b) : JSON.load(b.to_json)
        deep_compare_excluding_wildcards(a,b)
      end
      def deep_compare_excluding_wildcards(a,b)
        return false if a.class != b.class
        if a.is_a?(Hash)
          return false if a.size != b.size
          a.each do |k,v|
            return false if deep_compare_excluding_wildcards(v,b[k]) == false
          end
        elsif a.is_a?(Array)
          return false if a.size != b.size
          a.each_with_index{|e,i| return false if deep_compare_excluding_wildcards(e,b[i]) == false }
        else
          return (a == "*") || (b == "*") || (a == b)
        end
        true
      end

      alias :normalize :to_normalized_string
      
      def generate_api_id
        UUIDTools::UUID.random_create.to_s
      end
    end
  end
end
