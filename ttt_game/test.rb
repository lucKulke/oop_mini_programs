require "yaml"
MESSAGES = YAML.load_file("messages.yml")

class Test
  def promt
    puts MESSAGES['welcome']
  end
end

Test.new.promt