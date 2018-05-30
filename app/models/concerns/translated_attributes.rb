module TranslatedAttributes
  extend ActiveSupport::Concern

  class_methods do
    def translated_attributes(*attrs)
      attrs.each do |attr|
        column = attr.to_s.pluralize
        define_method(attr) { self[column][I18n.locale.to_s] }
        define_method("#{attr}=") { |str|
          self[attr] = str if self.class.column_names.include?(attr.to_s)
          self[column][I18n.locale.to_s] = str
        }
      end
    end

    def human_label(attr, locale)
      txt = human_attribute_name(attr)
      if Current.acp.languages.many?
        txt += " (#{I18n.t("languages.#{locale}")})"
      end
      txt
    end
  end
end
