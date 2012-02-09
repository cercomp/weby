#Esse tipo de input coloca a classe 'datetimepicker'
#e seta o valor do input através do attributo como Date, porque assim ele leva em consideração o timezone
#Que é o padrão pra datetime agora
#
#**Essa classe foi criada pois se utilizar StringInput para campos data, ele mostrará como ela está no banco,
#ou seja em UTC, mas o comportamente desejado é mostrar levando em consideração o time zone.
#
#Exemplo:
#
#    f.input :date_begin_at,
#            label: false,
#            wrapper_html: {class: "side"},
#            placeholder: t("begin")
#
class DateTimeInput < SimpleForm::Inputs::DateTimeInput
  def input
    input_html_options[:class] << " datetimepicker"
    input_html_options[:value] = @builder.object[@attribute_name] ? @builder.object[@attribute_name].strftime('%Y-%m-%d %H:%M') : ''
    @builder.text_field(attribute_name, input_html_options).html_safe
  end
end