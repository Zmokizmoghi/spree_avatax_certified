class SpreeAvataxCertified::Request::ListTransactions
  def generate(start_date, end_date)
    {
      filter: "date between #{start_date} and #{end_date}",
      top: 500
    }
  end

end
