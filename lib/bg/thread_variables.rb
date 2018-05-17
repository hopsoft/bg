module Bg::ThreadVariables
  def get_thread_variables
    Thread.current.thread_variables.each_with_object({}) do |key, memo|
      memo[key] = Thread.current.thread_variable_get(key)
    end
  end

  def set_thread_variables(thread_variables={})
    thread_variables.each do |key, value|
      Thread.current.thread_variable_set key, value
    end
  end

  def with_thread_variables(thread_variables={})
    previous_thread_variables = get_thread_variables
    set_thread_variables thread_variables
    begin
      yield
    ensure
      set_thread_variables previous_thread_variables
    end
  end
end
