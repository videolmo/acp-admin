module BulkDatesInsert
  extend ActiveSupport::Concern

  included do
    attr_accessor \
      :bulk_dates_starts_on,
      :bulk_dates_ends_on,
      :bulk_dates_weeks_frequency,
      :bulk_dates_wdays

    with_options if: :date? do
      validates :bulk_dates_starts_on, absence: true
      validates :bulk_dates_ends_on, absence: true
      validates :bulk_dates_weeks_frequency, absence: true
      validates :bulk_dates_wdays, absence: true
    end
    with_options unless: :date? do
      validates :bulk_dates_starts_on, presence: true
      validates :bulk_dates_starts_on, date: { before: :bulk_dates_ends_on }, if: :bulk_dates_ends_on
      validates :bulk_dates_ends_on, presence: true
      validates :bulk_dates_ends_on, date: { after: :bulk_dates_starts_on }, if: :bulk_dates_starts_on
      validates :bulk_dates_weeks_frequency, inclusion: { in: 1..4 }, presence: true
      validates :bulk_dates_wdays, presence: true
      # validate bulk_dates presence => error on :bulk_dates_wdays
      # validate bulk_dates_starts_on, bulk_dates_ends_on are in same fiscal_year
    end
  end

  def save
    if date?
      super
    else
      run_callbacks(:save) {
        self.class.bulk_insert values: bulk_dates.map { |date|
          attributes.except('created_at', 'updated_at').merge('date' => date)
        }
      }
    end
  end

  def bulk_dates_wdays=(wdays)
    super wdays & Array(0..6)
  end

  def bulk_dates
    return @dates if defined? @dates
    return if date?

    d = bulk_dates_starts_on
    @dates = []

    while d <= bulk_dates_ends_on
      @dates << d if bulk_dates_wdays.include?(d.wday)
      if d.sunday?
        d = (d + bulk_dates_weeks_frequency.weeks).monday
      else
        d += 1.day
      end
    end

    @dates
  end
end
