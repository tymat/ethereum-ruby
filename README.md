ethereum-ruby
=============

Ethereum JSON-RPC Ruby Bindings


usage
=====

```
require 'ethereum'

e = Ethereum::Connection.new
balance = e.get_balance_at('004ec17c4c9508fbb8d9834f960df510e2f7127f')
key = e.get_key
block = e.get_block('677f6161cec215e76897be5018606b2f4cedc146f93ae98ea5b8c60ee9f60c55')
block2 = e.get_block('b7c90d36e8fda8853cd7139af363fdf84359b3539106c91e085b706c935749f7')
con = e.create("test.init", "test.mut", "300", "1000000000", "20")
tx = e.transact('4287eaf147e1b4fc811fd68d1f70a51f13953766', '300', '100', '200')
```


todo
====

1. Create rubygem package
2. Test suite
