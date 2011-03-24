module Enumerable
  if ! instance_methods.find{|method| method.to_sym == :uniq_by}
    # File activesupport/lib/active_support/core_ext/array/uniq_by.rb, line 7
    def uniq_by
      hash, array = {}, []
      each { |i| hash[yield(i)] ||= (array << i) }
      array
    end
  end

end
