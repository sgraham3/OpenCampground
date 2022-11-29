document.addEventListener('DOMContentLoaded', function (event) {

    let defaultStyle = {border: '1px solid black',
	'font-size': '14px',
	padding: '3px',
	width: '250px'
    };
		    
    let validStyle = {
	border: '3px solid green',
	'font-size': '14px',
	padding: '3px',
	width: '250px'
    };   

    let invalidStyle = {
	border: '3px solid red',
	'font-size': '14px',
	padding: '3px',
	width: '250px'
    };

    /*
     * [optional]
     * you can enable allowing the user to submit the form by pressing the 'enter' key on their keyboard when the ifield is focused by calling
     * enableautosubmit(formelementid)
     * 
     * the formelementid is the id of your form that gets submit when the user presses 'enter' on their keyboard.
     * 
     * note: if this feature is enabled, the gettokens must be handled in a submit event listener for the form as that event is what gets triggered.
     */
    // enableAutoSubmit('payment-form');
    
    /*
    * [Optional]
    * You can enable 3DS Protection using enable3DS(amountElementId, monthElementId, yearElementId, waitForResponse, waitForResponseTimeout)
    *
    * The amountElementId, monthElementId, and yearElementId parameters are the ids for the html elements that contain the resepective values for those fields.
    * 
    * The waitForResponse parameter is an optional flag that indicates whether the getToken function should wait for 3DS data if it did not yet 
    * recieve it before generating the tokens (the default value is true). If the value is set to false, the tokens will be created without 3DS protection.
    * 
    * The waitForResponseTimeout parameter is how long it should wait for a 3DS response before creating the token without it (the default value is 20,000ms).
    *
    * Note: The timeout for waitForResponse and getToken are not cumulative. If they are the same value and the waitForResponse timeout is hit, the getToken timeout
    * will trigger as well.
    */
    // enable3DS('amount', 'month', 'year', true, 20000);

    /*
     * [Optional]
     * You can customize the iFields by passing in the appropriate css as JSON using setIfieldStyle(ifieldName, style)
     */
    // setIfieldStyle('ach', defaultStyle);
    setIfieldStyle('card-number', defaultStyle);
    setIfieldStyle('cvv', defaultStyle);

    /*
     * [Required]
     * Set your account data using setAccount(ifieldKey, yourSoftwareName, yourSoftwareVersion).
    setAccount('ifieldssamplekey_7e133696ce254383824cdff436c50c7b', 'iFields_Sample_Form', '1.0');
    setAccount("ifields_opencampgrdevbc9d2a5767b84811aee62dcd", "Open Campground", "0.1.2");
    setAccount("ifields_gooscreervmobihomepark2a426cebcd56457", "Open Campground", "0.1.2");
     */
    setAccount(window.ck_ifields_key, "Open Campground", "0.1.2");

    /*
     * [Optional]
     * Use enableAutoFormatting(separator) to automatically format the card number field making it easier to read
     * The function contains an optional parameter to set the separator used between the card number chunks (Default is a single space)
     */
    enableAutoFormatting();

    /*
     * [Optional]
     * Use addIfieldCallback(event, callback) to set callbacks for when the event is triggered inside the ifield
     * The callback function receives a single parameter with data about the state of the ifields
     * The data returned can be seen by using alert(JSON.stringify(data));
     * The available events are ['input', 'click', 'focus', 'dblclick', 'change', 'blur', 'keypress']
     * 
     * The below example shows a use case for this, where you want to visually alert the user regarding the validity of the card number, cvv and ach ifields
     */
     addIfieldCallback('input', function(data) {
	if (data.ifieldValueChanged) {
	    setIfieldStyle('card-number', data.cardNumberFormattedLength <= 0 ? defaultStyle : data.cardNumberIsValid ? validStyle : invalidStyle);
	    if (data.lastIfieldChanged === 'cvv'){
		setIfieldStyle('cvv', data.issuer === 'unknown' || data.cvvLength <= 0 ? defaultStyle : data.cvvIsValid ? validStyle : invalidStyle);
	    } else if (data.lastIfieldChanged === 'card-number') {
		if (data.issuer === 'unknown' || data.cvvLength <= 0) {
		    setIfieldStyle('cvv', defaultStyle);
		} else if (data.issuer === 'amex'){
		    setIfieldStyle('cvv', data.cvvLength === 4 ? validStyle : invalidStyle);
		} else {
		    setIfieldStyle('cvv', data.cvvLength === 3 ? validStyle : invalidStyle);
		}
	    } else if (data.lastIfieldChanged === 'ach') {
		setIfieldStyle('ach',  data.achLength === 0 ? defaultStyle : data.achIsValid ? validStyle : invalidStyle);
	    }
	}
    });

    /*
     * [Optional]
     * You can set focus on an ifield by calling focusIfield(ifieldName), in this case a delay is added to ensure the iframe has time to load
     */ 
    let checkCardLoaded = setInterval(function() {
	clearInterval(checkCardLoaded);
	focusIfield('card-number');
    }, 1000);

    /*
     * [Optional]
     * You can clear the ifield by calling clearIfield(ifieldName)
    document.getElementById('clear-btn').addEventListener('click', function(e){
	e.preventDefault();
	clearIfield('card-number');
	clearIfield('cvv');
      //   clearIfield('ach');
    });
     */

    /*
     * [Required]
     * Call getTokens(onSuccess, onError, [timeout]) to create the SUTs. * Pass in callback functions for onSuccess and onError. Timeout is an optional 
     * parameter that will exit the function if the call to retrieve the SUTs take too long. The default timeout is 60 seconds. It takes an number value
     * marking the number of milliseconds.
     * 
     * If autoSubmit is enabled, this must be done in a submit event listener for the form element.
     */
    document.getElementById('payment-form').addEventListener('submit', function(e){
	e.preventDefault();
	document.getElementById('transaction-status').innerHTML = 'Processing Transaction...';
	let submitBtn = this;
	submitBtn.disabled = true;
	getTokens(function() { 
		document.getElementById('transaction-status').innerHTML  = '';
      // 	  document.getElementById('ach-token').innerHTML = document.querySelector("[data-ifields-id='ach-token']").value;
		document.getElementById('card-token').innerHTML = document.querySelector("[data-ifields-id='card-number-token']").value;
		document.getElementById('cvv-token').innerHTML = document.querySelector("[data-ifields-id='cvv-token']").value;
		submitBtn.disabled = false;

		//The following line of code has been commented out for the benefit of the sample form. Uncomment this line on your actual webpage.
		document.getElementById('payment-form').submit();
	    },
	    function() {
		document.getElementById('transaction-status').innerHTML = '';
		// document.getElementById('ach-token').innerHTML = '';
		document.getElementById('card-token').innerHTML = '';
		document.getElementById('cvv-token').innerHTML = '';
		submitBtn.disabled = false;
	    },
		  30000
		 );
    });
});
