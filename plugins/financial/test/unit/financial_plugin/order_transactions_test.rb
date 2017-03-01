require_relative '../../test_helper'

class FinancialPlugin::OrderTransactionsTest < ActiveSupport::TestCase

  include OrdersTestHelper

  should 'Do not create a transaction when an order is saved without changing its value' do
    sale = create_default_sale_with_item cycle, profile
    sale.status = 'ordered'
    sale.save
    transactions = sale.financial_transactions

    sale.status = 'received'
    sale.save

    assert_equal transactions, sale.reload.financial_transactions
  end

  should 'Do not create a transaction when an order is just created as draft or new' do
    sale = create_default_sale_with_item cycle, profile
    assert sale.financial_transactions.empty?
  end

  should 'create a transaction when an order is confirmed' do
    sale = create_default_sale_with_item cycle, profile
    total = sale.total
    sale.status = 'ordered'
    sale.save

    assert_equal total, sale.reload.financial_transactions.sum(:value)
  end

  should 'zero the sum of the order transactions when its state is changed to draft' do
    sale = create_default_sale_with_item cycle, profile

    sale.status = 'ordered'
    sale.save

    sale.status = 'draft'
    sale.save

    assert_equal 0, sale.reload.financial_transactions.sum(:value)
  end

  should 'update the transactions sum when an order has its value changed' do
    sale = create_default_sale_with_item cycle, profile
    total = sale.total
    sale.status = 'ordered'
    sale.save

    total = sale.financial_transactions.sum(:value)

    item = sale.items.first
    item.update_attribute :quantity_consumer_ordered, 20

    v = sale.reload.financial_transactions.sum(:value)
    f = 20*item.price
    assert_equal v, f

  end

end
