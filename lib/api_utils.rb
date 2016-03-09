require 'rexml/document'

module ApiUtils

  def self.camelize_with_space(str)
    str.split('_').map {|w| w.capitalize}.join(' ')
  end

  def self.string_to_method_name(st)
    st.gsub(' ', '_').downcase
  end

  def self.string_to_symbol(st)



    st.gsub!(/[()%]*/, '')
    st.gsub(' ', '_').downcase.to_sym
  end

  def self.symbol_to_string(sym)
    sym.class == Symbol ? self.camelize_with_space(sym.to_s) : self.camelize_with_space(sym)
  end

  def self.sanitize_string(st)
   # debugger if st.match(/[\W+]/) #matvh se trova almeno un carattere speciale
    st
  end
end