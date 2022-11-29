class CardCodes
  # response handling

  def self.avsResponse(avsresp)
    case avsresp
    when 'X'
      'Exact match 9 char ZIP'
    when 'Y'
      'Exact match 5 char ZIP'
    when 'A'
      'Address match only'
    when 'W'
      '9 char ZIP match only'
    when 'Z'
      '5 char ZIP match only'
    when 'N' 
      'No address or ZIP match'
    when 'U'
      'Address unavailable'
    when 'G'
      'Non-US.  Issuer does not participate'
    when 'R'
      'Issuer system unavailable'
    when 'E'
      'Not a mail/phone order'
    when 'S'
      'Service not supported'
    else
      ' '
    end
  end

  def self.responseCode(respcode)
    code = respcode[1..2]
    case code
    # approvals
    when '00','11','85'
      # 00,Approval,Approved and completed
      # 08,Honor MasterCard with ID
      # 11,VIP approval
      # 85,,No reason to decline
      "Approved"
    when '08'
      # 08,Honor MasterCard with ID
      "Approved, Honor MasterCard with ID"
    # declines
    when '01','02'
      "Refer to issuer (Error code #{code})" 
    when '05'
      "Decline (Error code #{code})"
    when '51'
      "Decline,Insufficient funds (Error code #{code})"
    when '57'
      "Decline,Exceeds daily limit (Error code #{code})"
    when '61'
      "Declined,Exceeds withdrawal limit (Error code #{code})"
    when '62'
      "Declined, Invalid service code, restricted (Error code #{code})"
    when '93'
      "Decline, Violation, cannot complete (Error code #{code})"
    # pick up card
    when '04'
      "Pick up card (no fraud) (Error code #{code})"
    when '07'
      "Pick up card, special condition (fraud) (Error code #{code})"
    when '41'
      "Lost card, pick up (fraud account) (Error code #{code})"
    when '43'
      "Stolen card, pick up (fraud account) (Error code #{code})"
    # entry or account errors
    when '14'
      "Invalid card number (Error code #{code})"
    when '19'
      "Re-enter transaction (Error code #{code})"
    when '39'
      "No credit account (Error code #{code})"
    when '52'
      "No checking account (Error code #{code})"
    when '53'
      "No savings account (Error code #{code})"
    when '54'
      "Expired card (Error code #{code})"
    when '55'
      "Incorrect PIN (Error code #{code})"
    when '82'
      "CVV data is not correct (Error code #{code})"
    when 'N7'
      "CVV2 Value supplied is invalid (Error code #{code})"
    when '83'
      "Cannot verify PIN (Error code #{code})"
    when '86'
      "Cannot verify PIN (Error code #{code})"
    when '75'
      "PIN tried exceeded (Error code #{code})"
    # system or configuration errors
    when '03'
      "Invalid Merchant ID (Error code #{code})"
    when '06'
      "General error (Error code #{code})"
    when '10'
      "Partial approval for the authorized amount returned in Group III version 022 (Error code #{code})"
    when '12'
      "Invalid transaction (Error code #{code})"
    when '13'
      "Invalid amount (Error code #{code})"
    when '15'
      "No such issuer (Error code #{code})"
    when '21'
      "No Action Taken, Unable to back out transaction (Error code #{code})"
    when '28'
      "No Reply,File is temporarily unavailable (Error code #{code})"
    when '30'
      "Discover format error (Error code #{code})"
    when '34'
      "MasterCard use only, Transaction Canceled; Fraud Concern (Error code #{code})"
    when '57'
      "Transaction not permitted-Card (Error code #{code})"
    when '58'
      "Transaction not permitted-Terminal (Error code #{code})"
    when '59'
      "Transaction not permitted-Merchant (Error code #{code})"
    when '63'
      "Security violation (Error code #{code})"
    when '65'
      "Declined,Activity limit exceeded (Error code #{code})"
    when '76'
      "Unable to locate, no match (Error code #{code})"
    when '77'
      "Inconsistent data, reversed, or repeat (Error code #{code})"
    when '78'
      "No account (Error code #{code})"
    when '79'
      "Already reversed at switch (Error code #{code})"
    when '80'
      "Invalid date (Error code #{code})"
    when '80'
      "No Financial impact (used in reversal ,,responses to declined originals) (Error code #{code})"
    when '81'
      "Cryptographic error (Error code #{code})"
    when '91'
      "Issuer or switch is unavailable (Error code #{code})"
    when '92'
      "Invalid Routing, Destination not found (Error code #{code})"
    when '94'
      "Duplicate Trans, Unable to locate, no match (Error code #{code})"
    when '96'
      "System malfunction (Error code #{code})"
    when 'A1'
      "POS device authentication successful (Error code #{code})"
    when 'A2'
      "POS device authentication not successful (Error code #{code})"
    when 'A3'
      "POS device deactivation successful (Error code #{code})"
    when 'B1'
      "Surcharge amount not permitted on debit cards or EBT food stamps (Error code #{code})"
    when 'B2'
      "Surcharge amount not supported by debit network issuer (Error code #{code})"
    when 'CV'
      "Card Type Verification Error (Error code #{code})"
    when 'E1'
      "Encryption is not configured (Error code #{code})"
    when 'E2'
      "Terminal is not authenticated (Error code #{code})"
    when 'E3'
      "Data could not be decrypted (Error code #{code})"
    when 'EA'
      "Acct Length Err,Verification error (Error code #{code})"
    when 'EB'
      "Check Digit Err,Verification error (Error code #{code})"
    when 'EC'
      "CID Format Error,Verification error (Error code #{code})"
    when 'H6'
      "PIN pad encryption information for debit transaction received an error. (Error code #{code})"
    when 'HV'
      "Hierarchy Verification Error (Error code #{code})"
    when 'K0'
      "Token request was processed (Error code #{code})"
    when 'K1'
      "Tokenization is not configured (Error code #{code})"
    when 'K2'
      "Terminal is not authenticated (Error code #{code})"
    when 'K3'
      "Data could not be de-tokenized (Error code #{code})"
    when 'N3'
      "Cash back service not available (Error code #{code})"
    when 'N4'
      "Decline,Exceeds issuer withdrawal limit (Error code #{code})"
    when 'R0'
      "Customer requested stop of specific recurring payment (Error code #{code})"
    when 'R1'
      "Customer requested stop of all recurring payments from specific merchant (Error code #{code})"
    when 'T0'
      "Approval,First check is OK and has been converted (Error code #{code})"
    when 'T1'
      "Cannot Convert,Check is OK but cannot be converted ,,Note: This is a declined transaction (Error code #{code})"
    when 'T2'
      "Invalid ABA number, not an ACH participant (Error code #{code})"
    when 'T3'
      "Amount greater than the limit (Error code #{code})"
    when 'T4'
      "Unpaid items, failed negative file check (Error code #{code})"
    when 'T5'
      "Duplicate check number (Error code #{code})"
    when 'T6'
      "MICR error (Error code #{code})"
    when 'T7'
      "Too many checks (over merchant or bank limit) (Error code #{code})"
    when 'V1'
      "Daily threshold exceeded (Error code #{code})"
    when '06'
      "(Check Service Custom Text),Error response text from check service (Error code #{code})"
    else 
      "Code #{code} unknown"
    end
  end
  
end
