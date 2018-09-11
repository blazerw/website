class LiveCodeSegment < Hyperloop::Component
  param :content
  param :code

  before_mount do
    mutate.ruby_code params.code
  end

  render(DIV) do
    Sem.Divider(hidden: true)

    Sem.Grid(columns: 3, relaxed: false, padded: false) do
      Sem.GridColumn(width: 4) { params.content }
      Sem.GridColumn(width: 9) { code_mirror_editor }
      Sem.GridColumn(width: 3) do
        unless compile && evaluate && render_component
          Sem.Message(negative: true) {
            H3 { state.compile_error_heading }
            P { state.compile_error_message }
          }
        end
      end
    end
  end

  def code_mirror_editor
    options = {
      lineNumbers: false,
      mode: :ruby,
      theme: 'one-dark',
      indentUnit: 2,
      matchBrackets: true
    }
    ReactCodeMirror(options: options.to_n, value: state.ruby_code.to_n, onChange: lambda { |value| mutate.ruby_code value })
  end

  def compile
    begin
      @compiled_code = Opal::Compiler.new(state.ruby_code).compile
    rescue Exception => e
      mutate.compile_error_heading "Compile error"
      mutate.compile_error_message e.message
      return false
    end
    true
  end

  def evaluate
    begin
      `eval(#{@compiled_code})`
    rescue Exception => e
      mutate.compile_error_heading "Evaluation error"
      mutate.compile_error_message e.message
      return false
    end
    true
  end

  def render_component
    begin
      DIV(id: 'result') do
        # TODO this needs to throw an exception
        React.create_element( Module.const_get(component_name), {key: rand(2**256).to_s(36)[0..7]})
      end
    rescue Exception => e
      mutate.compile_error_heading "Invalid component error"
      mutate.compile_error_message e.message
      return false
    end
    true
  end

  def component_name
    elements = state.ruby_code.split ' '
    elements[ (elements.index('Hyperloop::Component') -2) ]
  end

end