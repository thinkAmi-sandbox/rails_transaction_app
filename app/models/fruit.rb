class Fruit < ApplicationRecord
  def self.save_with_invalid_transaction(params, type_name)
    ActiveRecord::Base.transaction do
      status = Status.find_by_key('fruit')
      status.name = 'success'
      status.save!

      fruit = Fruit.new(params)
      fruit.save!

      save_by_api
      true
    rescue StandardError
      status = Status.find_by_key('fruit')
      status.name = "error - #{type_name}"
      status.save!

      false
    end
  end

  def self.save_with_valid_transaction(params, type_name)
    ActiveRecord::Base.transaction do
      puts "現在のトランザクション数 : #{ActiveRecord::Base.connection.open_transactions}"

      status = Status.find_by_key('fruit')
      status.name = 'success'
      status.save!

      fruit = Fruit.new(params)
      fruit.save!

      save_by_api
      true
    end

  rescue StandardError
    status = Status.find_by_key('fruit')
    status.name = "error - #{type_name}"
    status.save!

    false
  end

  def self.save_with_new_transaction(params, type_name)
    ActiveRecord::Base.transaction(requires_new: true, joinable: false) do
      puts "現在のトランザクション数 : #{ActiveRecord::Base.connection.open_transactions}"

      status = Status.find_by_key('fruit')
      status.name = 'success'
      status.save!

      fruit = Fruit.new(params)
      fruit.save!

      save_by_api
      true
    end

  rescue StandardError
    status = Status.find_by_key('fruit')
    status.name = "error - #{type_name}"
    status.save!

    false
  end


  def self.rollback_by_parent(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、親でロールバック発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name: '親', description: "[親でロールバック] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name: '自身', description: "[親でロールバック] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name: '子', description: "[親でロールバック] 子: requires_new=#{requires_new} joinable=#{joinable}")
        end
      end

      raise ActiveRecord::Rollback
    end
  end

  def self.rollback_by_self(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、自身でロールバック発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name: '親', description: "[自身でロールバック] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name: '自身', description: "[自身でロールバック] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name: '子', description: "[自身でロールバック] 子: requires_new=#{requires_new} joinable=#{joinable}")
        end

        raise ActiveRecord::Rollback
      end
    end
  end

  def self.rollback_by_child(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、子でロールバック発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name: '親', description: "[子でロールバック] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name: '自身', description: "[子でロールバック] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name: '子', description: "[子でロールバック] 子: requires_new=#{requires_new} joinable=#{joinable}")

          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def self.exception_by_parent(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、親で例外発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name: '親', description: "[親で例外] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name: '自身', description: "[親で例外] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name: '子', description: "[親で例外] 子: requires_new=#{requires_new} joinable=#{joinable}")
        end
      end

      raise StandardError
    end

  rescue StandardError => e
    puts e
  end

  def self.exception_by_self(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、自身で例外発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name: '親', description: "[自身で例外] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name: '自身', description: "[自身で例外] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name: '子', description: "[自身で例外] 子: requires_new=#{requires_new} joinable=#{joinable}")
        end

        save_by_api
      end
    end

  rescue StandardError => e
    puts e
  end

  def self.exception_by_child(requires_new:, joinable:)
    puts "==== #{__method__}, requires_new #{requires_new}, joinable: #{joinable} ====>"
    puts "親のトランザクションの外 : #{ActiveRecord::Base.connection.open_transactions}"

    # すべて実行した後に、子で例外発生
    ActiveRecord::Base.transaction do
      puts "親のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
      Fruit.create!(name:'親', description: "[子で例外] 親: requires_new=#{requires_new} joinable=#{joinable}")

      ActiveRecord::Base.transaction(requires_new: requires_new, joinable: joinable) do
        puts "自身のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
        Fruit.create!(name:'自身', description: "[子で例外] 自身: requires_new=#{requires_new} joinable=#{joinable}")

        ActiveRecord::Base.transaction do
          puts "子のトランザクションの中 : #{ActiveRecord::Base.connection.open_transactions}"
          Fruit.create!(name:'子', description: "[子で例外] 子: requires_new=#{requires_new} joinable=#{joinable}")

          save_by_api
        end
      end
    end

  rescue StandardError => e
    puts e
  end

  private

  def self.save_by_api
    # 外部APIで保存エラーになるとする
    raise StandardError
  end
end
