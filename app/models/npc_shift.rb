class NpcShift < ApplicationRecord
  belongs_to :character_event, inverse_of: :npc_shifts
  belongs_to :bank_transaction, required: false

  delegate :character, :event, :accumulated_npc_money, to: :character_event
  alias_method :etd_pay, :accumulated_npc_money # event-to-date (like ytd)

  delegate :funds, to: :bank_transaction, allow_nil: true

  before_destroy :reverse_payments, if: Proc.new { |ns| ns.bank_transaction.present? }

  MAX_MONEY = Money.new(2000, :vmk)
  LIMIT_REACHED_MSG = "Bank Contract limits contractors to #{MAX_MONEY} per market day."

  MONEY_CLEAN = Money.new(200, :vmk)
  MONEY_DIRTY = Money.new(100, :vmk)

  validates_presence_of :character_event
  validate :disable_simultaneous_shifts

  scope :active,            -> { where(closing: nil).where.not(opening: nil) }
  scope :recently_closed, -> { where.not(closing: nil).order(closing: :desc).limit(5) }

  def real_pay
    self.try(:bank_transaction).try(:funds)
  end

  def pay_memo_msg
    @pay_memo_msg ||= "Bank Work (Shift ##{self.id}) for #{self.event.weekend}."
  end

  def disable_simultaneous_shifts
    if another_already_opened?
      errors[:base] << "This character already has a shift open this event."
    end
  end

  def another_already_opened?
    NpcShift.where(character_event: event).active.count != 0
  end

  def open_shift(opening=Time.now.utc)
    return false if another_already_opened?
    update(opening: opening.floor_to(15.minutes))
  end

  def close_shift(closing=Time.now.utc)
    return false if opening == nil
    self.update(closing: closing.ceil_to(15.minutes))
    issue_awards_for_shift! if character_event.paid?
  end

  def net_pay
    @net_pay ||= [gross_pay, MAX_MONEY-etd_pay].min
  end

  def current_event?
    character.last_event == event
  end

  def shift_length # in hours as a float so we can do partial payments
    shift_end = closing.present? ? closing : Time.now.ceil_to(15.minutes)
    (shift_end - opening).to_f / (60*60)
  end

  def display_name
    "#{character.display_name}'s #{event.display_name} Shift from #{opening} to #{closing}"
  end

  private

  def gross_pay
    @gross_pay ||= Money.new(shift_length * pay_rate, :vmk)
  end

  def pay_rate # hourly
    @pay_rate ||= (dirty? ? MONEY_CLEAN + MONEY_DIRTY : MONEY_CLEAN)
  end


  def issue_awards_for_shift!
    # Respect the per-event cap for payments
    memo_msg = (net_pay > Money.new(0, :vmk)) ? pay_memo_msg : "#{pay_memo_msg}\n#{LIMIT_REACHED_MSG}"

    ActiveRecord::Base.transaction do
      character_event.update!(accumulated_npc_money: (etd_pay+net_pay))
      create_bank_transaction!(to_account: character.primary_bank_account,
                                    funds: net_pay,
                                    memo: memo_msg)
    end
    save
  end

  def reverse_payments
    ActiveRecord::Base.transaction do
      character_event.update!(accumulated_npc_money: etd_pay-real_pay)
      payment = bank_transaction
      update_columns(bank_transaction_id: nil)
      payment.destroy!
    end
  end
end