require 'rails_helper'

RSpec.describe Fruit, type: :model do
  describe '#rollback_by_xxx系 のトランザクションの設定とロールバック状況' do
    context 'requires_new: false, joinable: false' do
      context '親でロールバック' do
        it 'すべてロールバック' do
          Fruit.rollback_by_parent(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身でロールバック' do
        it '親のトランザクションに参加しているため、自身のロールバックが握りつぶされて、親・自身・子のデータは残ったまま' do
          Fruit.rollback_by_self(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 3
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
          expect(Fruit.find_by(name: '子')).to be_truthy
        end
      end

      context '子でロールバック' do
        it '親のトランザクションに参加しているため、子のロールバックが握りつぶされて、親・自身・子のデータは残ったまま' do
          Fruit.rollback_by_child(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 3
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
          expect(Fruit.find_by(name: '子')).to be_truthy
        end
      end
    end

    context 'requires_new: false, joinable: true (デフォルト設定)' do
      context '親でロールバック' do
        it 'すべてロールバック' do
          Fruit.rollback_by_parent(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身でロールバック' do
        it '親のトランザクションに参加しているため、自身のロールバックが握りつぶされて、親・自身・子のデータは残ったまま' do
          Fruit.rollback_by_self(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 3
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
          expect(Fruit.find_by(name: '子')).to be_truthy
        end
      end

      context '子でロールバック' do
        it '親のトランザクションに参加しているため、子のロールバックが握りつぶされて、親・自身・子のデータは残ったまま' do
          Fruit.rollback_by_child(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 3
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
          expect(Fruit.find_by(name: '子')).to be_truthy
        end
      end
    end

    context 'requires_new: true, joinable: false' do
      context '親でロールバック' do
        it 'すべてロールバック' do
          Fruit.rollback_by_parent(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身でロールバック' do
        it '親・自身・子はそれぞれ別トランザクションのため、自身とそのネストしたトランザクションの子はロールバックするが、親は残る' do
          Fruit.rollback_by_self(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 1
          expect(Fruit.find_by(name: '親')).to be_truthy
        end
      end

      context '子でロールバック' do
        it '親・自身・子はそれぞれ別トランザクションのため、子はロールバックするが、親・自身は残る' do
          Fruit.rollback_by_child(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 2
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
        end
      end
    end

    context 'requires_new: true, joinable: true' do
      context '親でロールバック' do
        it '何も登録されていない' do
          Fruit.rollback_by_parent(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身でロールバック' do
        it '「親」と「自身・子」の2トランザクションにより、自身と子はロールバックするが、親のデータが残ったまま' do
          Fruit.rollback_by_self(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 1
          expect(Fruit.find_by(name: '親')).to be_truthy
        end
      end

      context '子でロールバック' do
        it '「親」と「自身・子」の2トランザクションは別、かつ、自身は子のロールバックを握りつぶすため、3件残ったまま' do
          Fruit.rollback_by_child(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 3
          expect(Fruit.find_by(name: '親')).to be_truthy
          expect(Fruit.find_by(name: '自身')).to be_truthy
          expect(Fruit.find_by(name: '子')).to be_truthy
        end
      end
    end
  end

  describe '#exception_by_xxx系 のトランザクションの設定とロールバック状況' do
    context 'requires_new: false, joinable: false' do
      context '親で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_parent(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_self(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '子で例外' do
        it 'すべて' do
          Fruit.exception_by_child(requires_new: false, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end
    end

    context 'requires_new: false, joinable: true' do
      context '親で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_parent(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_self(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '子で例外' do
        it 'すべて' do
          Fruit.exception_by_child(requires_new: false, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end
    end

    context 'requires_new: true, joinable: false' do
      context '親で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_parent(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_self(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '子で例外' do
        it 'すべて' do
          Fruit.exception_by_child(requires_new: true, joinable: false)

          expect(Fruit.all.count).to eq 0
        end
      end
    end

    context 'requires_new: true, joinable: true' do
      context '親で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_parent(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '自身で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_self(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end

      context '子で例外' do
        it 'すべてロールバック' do
          Fruit.exception_by_child(requires_new: true, joinable: true)

          expect(Fruit.all.count).to eq 0
        end
      end
    end
  end
end


