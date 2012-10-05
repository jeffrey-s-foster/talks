object @list
attribute :name
attribute :short_descr
attribute :long_descr
child(:talks) do |talk|
  extends "talks/show"
end
