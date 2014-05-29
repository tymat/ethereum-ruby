require 'socket'
require 'json'
require 'date'
require 'active_support/core_ext'

class Ethereum
  DEFAULT_PORT = 8080
  DEFAULT_HOST = 'localhost'
  class Connection
    attr_reader :socket
    def initialize(host = DEFAULT_HOST, port = DEFAULT_PORT)
      @socket = ::TCPSocket.new(host, port)
    end

    def send_command(request)
      b = @socket.puts(request.to_json) 
      response = @socket.gets
      response = ::JSON.parse(response)
      return ::JSON.parse(response["result"]) unless response["error"] 
    end

    def get_balance_at(address)
      request = {id: 1, method: "EthereumApi.GetBalanceAt", params: [{address: address}]} 
      response = send_command(request)
      return response["result"]["balance"] unless response["error"]
    end

    def get_block(hash)
      request = {id: 1, method: "EthereumApi.GetBlock", params: [{hash: hash}]} 
      response = send_command(request)
      return Block.new(response["result"]) unless response["error"]
    end

    def get_key
      request = {id: 1, method: "EthereumApi.GetKey", params: [{}]}
      response = send_command(request)
      return response["result"] unless response["error"]
    end

    def get_storage_at(address, key)
      request = {id: 1, method: "Ethereum.GetStorageAt", params: [{address: address, key: key}]} 
      response = send_command(request)
      return response["result"] unless response["error"]
    end

    def transact(recipient, value, gas, gas_price)
      request = {id: 1, method: "EthereumApi.Transact", params: [{recipient: recipient, value: value, gas: gas, gasprice: gas_price}]}
      puts request.to_json
      response = send_command(request)
      return response["result"] unless response["error"]
    end

    def create(init, body, value, gas, gas_price)
      init_content = ::File.read(init).gsub("\n", " ")
      body_content = ::File.read(body).gsub("\n", " ")
      request = {id: 1, method: "EthereumApi.Create", params: [{init: init_content, body: body_content, value: value, gas: gas, gasprice: gas_price}]}
      puts request.to_json
      response = send_command(request)
    end

  end

  class Block

    attr_reader :transactions, :hash, :number, :time
    def initialize(rawdata)
      @number, @hash, @time = rawdata["number"], rawdata["hash"], DateTime.strptime(rawdata["time"].to_s, '%s')
      transactions = rawdata["transactions"] == "null" ? nil : []
      if transactions != nil
        @transactions = []
        ::JSON.parse(rawdata["transactions"]).each do |tx|
          @transactions << Transaction.new(tx)
        end
      else
        @transactions = nil
      end
    end

  end

  class Transaction
    attr_reader :value, :gas, :gas_price, :hash, :address, :sender, :raw_data, :data, :is_contract, :creates_contract
    def initialize(txhash) 
      txhash.each do |key, value|
        self.instance_variable_set("@#{key.underscore}".to_sym, value)
      end
    end

    def is_contract?
      @is_contract
    end

    def creates_contract?
      @creates_contract
    end
  end

end

