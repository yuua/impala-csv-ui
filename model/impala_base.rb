require 'impala'
require 'yaml'
require 'csv'
require 'zip'

class ImpalaBase

  def cursor(sql,env)
    # sql操作
    conn = impala_connect(env)
    c = conn.execute(sql)
    file_name = make_file_name
    make_csv c,file_name
    conn.close
    
    # ファイル削除
    delete_file(file_name)
    "#{file_name}.zip"
  end

  def impala_connect(env)
    config = load_config
    config = config['impala'][env.to_s] #めんどいからto_s
    Impala.connect(config['address'],config['port'])
  end

  # 適当にcsvに書き込むやつ
  def make_csv(c,file_name)
    CSV.open("#{File.dirname(__FILE__)}/../csvs/#{file_name}.csv",'a') do |csv|
      # 最初の1件の処理
      first_val = c.first
      csv << first_val.keys
      csv << first_val.values
      c.each_with_index do |rows,i|
        csv << rows.values
        if i % 25000 == 0
          csv.flush
          sleep 0.5
        end
      end
    end
    zip_archives(file_name)
  end

  # 圧縮
  def zip_archives(file_name)
    Zip::File.open("#{File.dirname(__FILE__)}/../csvs/#{file_name}.zip", Zip::File::CREATE) do |zip_file|
      zip_file.add("#{file_name}.csv","#{File.dirname(__FILE__)}/../csvs/#{file_name}.csv")
    end
  end

  def delete_file(file_name)
    File.delete("#{File.dirname(__FILE__)}/../csvs/#{file_name}.csv")
  end

  # 適当にファイル名生成
  def make_file_name
    'result_' + Time.now.strftime('%Y%m%d_%H%I%S')
  end

  def load_config
    YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")
  end

end
