require 'json'
require 'securerandom'
require 'redis'
require 'haml'
require './model/hive_base'
require './model/impala_base'
# require 'sinatra/reloader'

class App < Sinatra::Base

  set :environment, ENV['RACK_ENV'].to_sym || :development 

  def initialize
    super
    @redis = Redis.new
  end

  get '/' do
    @title = 'beginer: for csv downloader'
    haml :index
  end

  post '/sql_exec' do
    # postを直接sqlで流すセキュリティ的によろしくないやつ
    data_name = ImpalaBase.new.cursor(params[:sql],settings.environment)

    # DL
    send_file("#{File.dirname(__FILE__)}/csvs/#{data_name}",filename: data_name, type: 'text/csv')
  end

  def execute(dt)
    HiveBase.new.execute {|con| create_partition(con,dt) }
  end

end
