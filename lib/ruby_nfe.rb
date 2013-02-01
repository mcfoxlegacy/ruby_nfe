# encoding: utf-8
require "ruby_nfe/version"
require "nokogiri"
require "haml"
require "i18n"
require "action_view"

include ActionView::Helpers::NumberHelper

$ruby_nfe_path_loaded = false

module RubyNfe

  class NfeToHtml
    attr_reader :xml

    def initialize(xml)
      @xml = Nokogiri::XML(xml)
      @xml.remove_namespaces!
    end
    
    def render_documento
      html = "<style type=\"text/css\">" + File.read(File.dirname(__FILE__) + "/estilos.css") + "</style>"
      html = html + render("documento", {:xml => @xml})
      html.html_safe
    end

  end
end

def render(partial, locals = {})
  return '' if partial.nil? || partial.empty?

  template = File.read(File.dirname(__FILE__) + "/views/_#{partial}.html.haml")
  Haml::Engine.new(template).render(Object.new, locals)
end

def render_nfe(xml)
  nota = RubyNfe::NfeToHtml.new(xml)
  nota.render_documento
end

# funções formatação
def number_to_currency_br(number)
  return '?' if number.nil?

  number_to_currency(number, :unit => "R$ ", :separator => ",", :delimiter => ".")
end

def number_with_delimiter_br(number)
  return '?' if number.nil?

  number_with_delimiter(number, :delimiter => ".", :separator => ",")
end

def format_date(dt)
  return '' if dt.nil?

  dt.strftime("%d/%b/%Y")
end

def codigo_e_descricao(cod, *escopo)
  return nil if cod.blank?

  if !$ruby_nfe_path_loaded
    I18n.load_path += Dir[File.expand_path(File.join(File.dirname(__FILE__), '/locales', '*.yml')).to_s]
    I18n.reload!
    $ruby_nfe_path_loaded = true
  end
  "#{cod} - #{I18n.t(cod, :default => '?', :locale => 'pt', :scope => %w(codigos) + escopo)}"
rescue => e
  cod
end

FORMAT_MASKS = {
  :fone => { :regex => /(..)(.{4,})(.{4})/, :replacement => '(\1) \2-\3' },
  :cep => { :size => 8, :regex => /(.....)(...)/, :replacement => '\1-\2' },
  :cpf => { :size => 11, :regex => /(...)(...)(...)(..)/, :replacement => '\1.\2.\3-\4' },
  :cnpj => { :size => 14, :regex => /(..)(...)(...)(....)(..)/, :replacement => '\1.\2.\3/\4-\5' },
  :chave => { :size => 44, :regex => /(..)(....)(.{14})(..)(...)(.{9})(.)(.{8})(.)/,
              :replacement => '\1 \2 \3 \4 \5 \6 \7 \8 \9' }
}

def f(s, options = { })
  return s if s.blank?

  mask = FORMAT_MASKS[options[:mask]]
  mask ||= FORMAT_MASKS.values.find { |v| v[:size] === s.size } if s.is_a?(String)

  mask ? s.gsub(mask[:regex], mask[:replacement]) : s
end