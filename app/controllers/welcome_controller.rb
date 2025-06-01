class WelcomeController < ApplicationController
  def index
#  	@entries = JournalEntry.all
# 取得所有會計科目
	@account_subjects = AccountSubject.all
  end
  
  def journal
	@journal_entries = JournalEntries.all.order(entry_date: :desc)
  end
  
  
  def test_count
  	@debit =0
  	@credit =0
  	@test_ount =AccountSubject.find_by_sql(<<-SQL)
  	SELECT subject,
	(SELECT ifnull(sum(debit_amount),0) FROM journal_entries
	WHERE debit_subject = subject)-
	(SELECT ifnull(sum(credit_amount),0) FROM journal_entries
	WHERE credit_subject = subject) as cal
	FROM `account_subjects` WHERE 1
SQL
  end
  def statement
   result= JournalEntries.find_by_sql("select min(entry_date) as val from journal_entries")
   @start_data = result.first.val
   result = JournalEntries.find_by_sql("select max(entry_date) as val from journal_entries")
   @end_data  = result.first.val
  #損益表
  result = JournalEntries.find_by_sql("select sum(credit_amount) as val from journal_entries
  where credit_subject = '銷貨收入'")
@sales_revenue = result.first.val

result = JournalEntries.find_by_sql("select sum(debit_amount) as val from journal_entries
  where debit_subject = '銷貨成本'")
@sales_cost = result.first.val

result = JournalEntries.find_by_sql("select sum(debit_amount) as val from journal_entries
  where debit_subject = '利息支出'")
@interest_expense = result.first.val


  @expenses = AccountSubject.find_by_sql(<<-SQL)
  select subject,
  (SELECT IFNULL(sum(debit_amount),0) 
  from journal_entries WHERE debit_subject = subject ) as val
  from account_subjects
  where category = '支出'
  and subject not in ('銷貨成本','利息支出')
SQL

  @net_income =  (@sales_revenue || 0) - (@sales_cost || 0) - (@interest_expense || 0)
  @expenses.each do |subject|
  	@net_income -= subject.val
  end

#資產負債表

@assets = AccountSubject.find_by_sql(<<-SQL)
  SELECT subject,
    (
      (SELECT IFNULL(SUM(debit_amount), 0) 
       FROM journal_entries 
       WHERE debit_subject = subject) -
      (SELECT IFNULL(SUM(credit_amount), 0) 
       FROM journal_entries 
       WHERE credit_subject = subject)
    ) AS val
  FROM account_subjects
  WHERE category = '資產'
SQL
@total_assets = 0
  @assets.each do |subject|
  	@total_assets += subject.val
  end

@liabilities = AccountSubject.find_by_sql(<<-SQL)
  SELECT subject,
    -1 *( #取正值
      (SELECT IFNULL(SUM(debit_amount), 0) 
       FROM journal_entries 
       WHERE debit_subject = subject) -
      (SELECT IFNULL(SUM(credit_amount), 0) 
       FROM journal_entries 
       WHERE credit_subject = subject)
    ) AS val
  FROM account_subjects
  WHERE category = '負債'
SQL

@total_liabilities = 0

  @liabilities.each do |subject|
  	@total_liabilities += subject.val
  end

@shareholder_equity = AccountSubject.find_by_sql(<<-SQL)
  SELECT subject,
    -1 *(
      (SELECT IFNULL(SUM(debit_amount), 0) 
       FROM journal_entries 
       WHERE debit_subject = subject) -
      (SELECT IFNULL(SUM(credit_amount), 0) 
       FROM journal_entries 
       WHERE credit_subject = subject)
    ) AS val
  FROM account_subjects
  WHERE category = '股東權益'
SQL

  @shareholder_equity.each do |subject|
  	@total_liabilities += subject.val
  end
  
@retained_earnings = @net_income
@total_liabilities += @retained_earnings
#現金流量表

#business
arr_business_debit = ["銷貨收入"]
sql = <<~SQL
select credit_subject,
  sum(credit_amount) as val
  from journal_entries
  where credit_subject in (?)
  and debit_subject = '現金'
  group by credit_subject
SQL
@business_debit = JournalEntries.find_by_sql(
  [sql,arr_business_debit]
)

arr_business_credit = ["商品存貨", "水電費","廣告支出"]
sql = <<~SQL
select debit_subject,
  -1 * sum(debit_amount) as val
  from journal_entries
  where debit_subject in (?)
  and credit_subject = '現金'
  group by debit_subject
SQL
@business_credit = JournalEntries.find_by_sql(
  [sql,arr_business_credit]
)
#invest
arr_invest = ["機器設備"]
sql = <<~SQL
select debit_subject,
  -1 * sum(debit_amount) as val
  from journal_entries
  where debit_subject in (?)
  and credit_subject = '現金'
  group by debit_subject
SQL
@invest_credit = JournalEntries.find_by_sql(
  [sql,arr_invest]
)

#financing
arr_financing_debit = ["業主資本"]
sql = <<~SQL
select credit_subject,
  sum(credit_amount) as val
  from journal_entries
  where credit_subject in (?)
  and debit_subject = '現金'
  group by credit_subject
SQL
@financing_debit = JournalEntries.find_by_sql(
  [sql,arr_financing_debit]
)

arr_financing_credit = ["業主往來"]
sql = <<~SQL
select debit_subject,
  -1 * sum(debit_amount) as val
  from journal_entries
  where debit_subject in (?)
  and credit_subject = '現金'
  group by debit_subject
SQL
@financing_credit = JournalEntries.find_by_sql(
  [sql,arr_financing_credit]
)


  end
  
end
