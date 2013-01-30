<?PHP
	/**
	* PassKit.php
	*
	* @author Thomas Smart <dev*ThomasSmart*c0m>
	* @copyright Thomas Smart <dev*ThomasSmart*c0m>
	* @license http://www.opensource.org/licenses/gpl-license.php
	* @package PassKitSDK
	*/

	/**
	* PassKit
	*
	* PassKit class for validating passes, adding value
	* deducting value and redeeming passes.
	*
	* @author Thomas Smart <dev*ThomasSmart*c0m>
	* @package PassKitSDK
	*/

	class PassKit{
		// {{{ properties

			/**
				* $api_url
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Initiate
				* @var String $api_url URL to PassKit API, includes version
			*/
			private $api_url = "https://api.passkit.com/v1/";

			/**
				* $account
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Initiate
				* @var String $account PassKit Account ID, Set with: __construct()
			*/
			private $account = "";

			/**
				* $secret
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Initiate
				* @var String $secret PassKit Account Secret, Set with: __construct()
			*/
			private $secret = "";

			/**
				* $debug
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Initiate
				* @var Boolean $debug Debug enabled or not, Set with: __construct()
			*/
			private $debug = false;


			/**
				* $pass_id
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Initiate
				* @var String $pass_id Pass ID we will work with, Set with: set_pass_id()
			*/
			private $pass_id = "";

			/**
				* $pass_details
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Pass Interaction
				* @var Array $pass_details Details for the currently validated pass, Set with: pass_details()
			*/
			private $pass_details = array();

			/**
				* $pk_result
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Pass Interaction
				* @var Object $pk_result JSON result for a passkit query, Set with pk_query()
			*/
			private $pk_result = NULL;

			/**
				* $pk_error_result
				*
				* @author Thomas Smart <dev*ThomasSmart*c0m>
				* @category Pass Interaction
				* @var Object $pk_error_result JSON error result for a passkit query, Set with pk_query();
		 	*/
		 	public $pk_error_result = "";
		// }}}



		/*************************************************************/
		/*	Initiate				 																				 */
		/*************************************************************/

		// {{{ __construct()
		/**
			* __construct
			*
			* Initial setup, needs passkit account key and secret
			* will return fail if either is empty. Optional debug
			* variable can also be set which will cause errors to be
			* printed on-screen.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Initiate
			* @access public
			* @param String $account PassKit Account ID (required)
			* @param String $secret PassKit Account Secret (required)
			* @param Boolean $debug Debug enabled or not (default: false)
			* @return Boolean True on successful connection
		*/
		public function __construct($account, $secret, $debug=false){
			// sanitize passed variables and save as properties
			$this->account	=	$this->sanitize($account);
			$this->secret		=	$this->sanitize($secret);
			$this->debug		=	$debug ? true:false;

			// values cannot be empty
			if($this->account==''){
				// Print error
				$this->error('Account ID is required. It cannot be empty and should be valid Base64 encoded.',debug_backtrace());

				// Return fail
				return false;
			}

			if($this->secret==''){
				// Print error
				$this->error('Account Secret is required. It cannot be empty and should be valid Base64 encoded.',debug_backtrace());

				// Return fail
				return false;
			}


			// return success
			return true;
		}
		// }}}



		/*************************************************************/
		/*	PassKit Communication 																	 */
		/*************************************************************/

		// {{{ pk_query()
		/**
			* PassKit Query
			*
			* The cURL query function to PassKit. Handles all generic parts
			* of this activity and can be called from action specific functions
			* that provide specific requests.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category PassKit Communication
			* @access private
			* @param String $path URL path to use for query
			* @param Array $post Additional post parameters to send with the query, optional
			* @return Boolean True on successful connection
		*/
		private function pk_query($path='',$post=array()) {
			// Full URL to use for the query
			$api_url =  $this->api_url.$path;

			// initiate curl
			$session = curl_init($api_url);

			// If post-field paramaters have been provided
			if(!empty($post)){
				// Set cURL post options
				curl_setopt ($session, CURLOPT_POST, true);
				curl_setopt ($session, CURLOPT_POSTFIELDS, $post);
			}

			// Set cURL options
			curl_setopt ($session, CURLOPT_HTTPAUTH, CURLAUTH_DIGEST);
			curl_setopt ($session, CURLOPT_HEADER, false);
			curl_setopt ($session, CURLOPT_RETURNTRANSFER, true);
			curl_setopt ($session, CURLOPT_SSL_VERIFYPEER, false); // required for older cURL libraries that don't support TLS

			// Account ID and secret
			curl_setopt ($session, CURLOPT_USERPWD, $this->account.':'.$this->secret);

			// Execute then close curl connection
			$response = curl_exec($session);
			curl_close($session);

			// If there is a response, then decode it into a JSON object
			$result = ($response ? json_decode($response) : false);

			// check if the success parameter is present and true
			if(isset($result->success) && $result->success){
				// Store the result object in the property
				$this->pk_result = $result;

				// Return success
				return true;
			}

			// An error occurred
			$this->pk_result = NULL;
			$this->pk_error_result = $result;

			// Print error
			$this->error('PassKit query error. Curl response: <pre>'.print_r($response,true).'</pre>',print_r(debug_backtrace(),true)); // debug the response;

			// Return fail
			return false;
		}
		// }}}

		// {{{ pk_test_connection()
		/**
			* Connection test
			*
			* Test PassKit connection and authentication
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category PassKit Communication
			* @access public
			* @return Boolean True on successful authentication
		*/
		public function pk_test_connection(){
			return $this->pk_query('authenticate/');
		}
		// }}}

		// {{{ pk_image_upload()
		/**
			* Image Upload
			*
			* Upload an image to PassKit where it can used for passes
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category PassKit Communication
			* @access public
			* @param String $role Which role should the image be optimised for. Valid values are 'icon', 'strip', 'logo', 'thumbnail', 'background' and 'footer'.
			* @param String $filename Local path to file
			* @return String The Image ID of the newly uploaded image which can be used to update a pass
			*
		*/
	 	public function pk_image_upload($role, $filename) {
			// Only specific roles are supported
			if(!in_array($role, array('background', 'footer', 'icon', 'logo', 'strip', 'thumbnail'))){
				$this->error('Invalid image type: "'.$role.'"',debug_backtrace());
				return false;
			}

			// file must exist
			if(!file_exists($filename)){
				$this->error('Image file not found',debug_backtrace());
				return false;
			}

			// only jpg, gif and png are supported
			$filetype = exif_imagetype($filename);
			if(!in_array($filetype,array(IMAGETYPE_GIF, IMAGETYPE_JPEG, IMAGETYPE_PNG))){
				$this->error('Image type not supported',debug_backtrace());
				return false;
			}else{
				switch($filetype){
					case IMAGETYPE_GIF:
						$filetype = 'gif';
						break;
					case IMAGETYPE_JPEG:
						$filetype = 'jpeg';
						break;
					case IMAGETYPE_PNG:
						$filetype = 'png';
						break;
				}
			}

			// max filesize is 1.5mb
			if(filesize($filename) > 1572864){

				// try to resize the image first, note that both the file and the directory it is in should be writeable by PHP
				// an uploaded file in /tmp/ would typically be fine
				$resized = false;

				// test imagick module
				if(extension_loaded('imagick')){
					// resize
					$image = new Imagick($filename);
					$resized = $image->resizeImage(1000,1000, imagick::FILTER_LANCZOS, 0.9, true);
					$image->writeImage($filename);
					$image->clear();
					$image->destroy();
				}

				// test imagick exe
				if(!$resized){
					exec("/usr/bin/convert -version", $out, $rcode);
					if($rcode===0){
						putenv("MAGICK_THREAD_LIMIT=1");
						exec("/usr/bin/convert $filename -resize '1000x1000>' /tmp/output.jpg; mv -f /tmp/output.jpg $filename; rm -rf /tmp/output.jpg");
						if(filesize($filename) < 1572864){
							$resized = true;
						}
					}
				}

				// test GD
				if(!$resized && extension_loaded('gd') && function_exists('gd_info')){
					// resize
					if($filetype=='gif'){		$img_src=imagecreatefromgif($filename);	}else
					if($filetype=='jpeg'){	$img_src=imagecreatefromjpeg($filename); }else
					if($filetype=='png'){		$img_src = imagecreatefrompng($filename);}
					if(isset($img_src)){
						$owidth = imagesx($img_src);
						$oheight = imagesy($img_src);
						$ratio = $owidth / $oheight;
						$twidth = $theight = min(1000, max($owidth, $oheight));
						if($ratio < 1){ $twidth  = $theight * $ratio; }
											else{	$theight = $twidth / $ratio; }

						$img_des = imagecreatetruecolor($twidth,$theight);
						imagecopyresampled($img_des, $img_src, 0, 0, 0, 0, $twidth, $theight, $owidth, $oheight);
						imagepng($img_des,$filename);
						if(filesize($filename) < 1572864){
							$filetype = 'png';
							$resized = true;
						}
					}
				}

				// alas, no resizing software, return error
				if(!$resized){
					$this->error('Image size too large, max size is 1572864 bytes (1.5mb)',debug_backtrace());
					return false;
				}
			}

			// all is well, upload to passkit
			if($this->pk_query('image/add/'.$role, array('image' => '@'.$filename.';type=image/'.$filetype ))){
				return $this->pk_result->imageID;
			}else{
				return false;
			}
		}
		// }}}

		// {{{ pk_issue_pass()
		/**
			* Issue Pass
			*
			* Issue a new Passbook Pass
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category PassKit Communication
			* @access public
			* @param	String $template Name of the template to generate a pass for
			* @param	Array $params Associated array of field names and values for dynamic fields
			* @param	Boolean $redirect redirect user to the pass in-browser once created
			* @return object object containing the URL, serial and Passbook serial of the issued pass, or error message on failure
			*
		*/
	 	public function pk_issue_pass($template, $params, $redirect=false){

			// Passthrough the referrer IP address - Note this does not work on IIS servers.
			if(isset($_SERVER['REMOTE_ADDR'])){
				$params['installIP'] = $_SERVER['REMOTE_ADDR'];
			}

			// create the new pass
			$newPass = $this->pk_query('pass/issue/template/'.$template, $params);

			// if success and redirect is set, send user to created pass on PassKit
			if($newPass && $redirect){
				header('location: '.$this->pk_result->url);
				exit();
			}

			// return creation result
			if($newPass){
				return $this->pk_result;
			}else{
				return $this->pk_error_result;
			}
		}
		// }}}


		/*************************************************************/
		/*	Validation and Retrieval			 					 */
		/*************************************************************/

		// {{{ set_pass_id()
		/**
			* Set pass ID
			*
			* Call this function with the Pass ID. It will be santized
			* and stored as a property. If it is empty it will return an error.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @param String $pass_id Pass code as scanned from barcode (required)
			* @return Boolean
		*/
		public function set_pass_id($pass_id) {

			// Split it up by "-" in case multiple strings have been passed
			$pass_id = explode('-',$pass_id);

			// Last one should be the PID (set with %pid in pass creator / front content / text to encode
			// santize this for security
			$this->pass_id = $this->sanitize($pass_id[count($pass_id)-1]);

			// Pass ID should not be empty
			if($pass_id == ''){
				// Print error
				$this->error('Pass ID is required and cannot be empty.',debug_backtrace());

				// Return fail
				return false;
			}

			// return success
			return true;
		}
		// }}}

		// {{{ set_pass_serial()
		/**
			* Set pass ID via serial
			*
			* Call this function with the params Pass Serial and Template Name.
			* Using these it will query PassKit for the Pass ID and feed that
			* into the set_pass_id function.
			*
			* set the Pass Serial and call set_pass_id()
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @param String $serial Pass serial (required)
			* @param String $template Pass template (required)
			* @return Boolean
		*/
		public function set_pass_serial($serial,$template) {
			// They should not be empty
			if($serial == '' || $template == ''){
				// Print error
				$this->error('Pass Serial and Template are required and cannot be empty.',debug_backtrace());

				// Return fail
				return false;
			}

			// send the template name and pass serial to passkit for a response
			// if the call fails then return fail
			if(!$this->pk_query("pass/get/template/$template/serial/$serial")){
				// Print error
				$this->error('Pass Serial and Template combination not recognized by PassKit.',debug_backtrace());

				// Return fail
				return false;
			}

			// If the pass ID does not exist in the return then return fail
			if(!isset($this->pk_result->uniqueID)){
				// Print error
				$this->error('Pass Serial and Template combination not recognized by PassKit.',debug_backtrace());

				// Return fail
				return false;
			}

			// query was success and we have a valid Pass ID. Send this to the set_pas_id
			// function to continue the flow as normal. Return the status of that function.
			return $this->set_pass_id($this->pk_result->uniqueID);
		}
		// }}}


		// {{{ pass_validate()
		/**
			* Validate Pass
			*
			* Validate the set Pass ID with PassKit
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @return Boolean True on successful validation
		*/
		public function pass_validate() {
			// a pass ID number is required
			if($this->pass_id==''){
				// Print error
				$this->error('Pass ID is required to be set before you can use this function. Please use the set_pass_id($pass_id) function to set the pass ID first.',debug_backtrace());

				// Return fail
				return false;
			}

			// Send call to PassKit to validate the pass and return details
			if(!$this->pk_query($url_path='pass/get/passid/'.$this->pass_id)){
				// Print error
				$this->error('PassKit was unable to provide pass details for the pass ID: '.$this->pass_id,debug_backtrace());

				// Return fail
				return false;
			}

			// Save pass details to the property
			$this->pass_details = array(
				"pass_pid"			=>	$this->pass_id,
				"serial_number"		=>	$this->pk_result->serialNumber,
				"template_name"		=>	$this->pk_result->templateName,
				"template_update"	=>	$this->pk_result->templateLastUpdated,
				"system_status"		=>	$this->pk_result->passRecord->passMeta->passStatus,
				"pass_data"			=>	$this->object2array($this->pk_result->passRecord->passData)
			);



			// if data-status is found then store in variable and delete from passdata array
			if(isset($this->pk_result->passRecord->passData->{'data-status'})){
				$pass_status = $this->pk_result->passRecord->passData->{'data-status'};
				unset($this->pk_result->passRecord->passData->{'data-status'});

			// not found so set default 'Available'
			}else{
				$pass_status = 'Available';
			}

			// set pass status in details
			$this->pass_details['pass_status'] = $pass_status;

			// Return success
			return true;
		}
		// }}}

		// {{{ get_pass_details()
		/**
			* Get Pass Details
			*
			* Return the pass details array. This can be used for storing a local
			* copy of the details for example or for customized processing.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @return Array pass details
		*/
		public function get_pass_details() {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return fail
				return false;
			}

			// return pass details
			return $this->pass_details;
		}
		// }}}

		// {{{ get_templates()
		/**
			* Get template names
			*
			* Return all PassKit template names for this account.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @return Array template names
		*/
		public function get_templates() {
			// query passkit for templates
			if(!$this->pk_query('template/list')){
				// Print error
				$this->error('Request for templates failed.',debug_backtrace());

				// Return fail
				return false;
			}

			// return templates
			return $this->object2array($this->pk_result->templates);
		}
		// }}}

		// {{{ get_template_details()
		/**
			* Get template details
			*
			* Return the template details, static and dynamic with default values.
			* Developer added "data-" entries are excluded.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Validation and Retrieval
			* @access public
			* @param	String $template name of the template to retrieve details for
			* @return Array pass details
		*/
		public function get_template_details($template) {
			// pass details are required
			if($template==''){
			  // Print error
				$this->error('Valid template name required.',debug_backtrace());

				// Return fail
				return false;
			}

			// Query passkit for template details for the provided template name. Convert to array for consistancy and cleaning
			$q = $this->pk_query('template/'.urlencode($template).'/fieldnames/full');
			if($q && isset($this->pk_result->{$template})){
				$template_details = $this->object2array($this->pk_result->{$template});
			}else{
				$template_details = array();
			}

			// Format the array in a consistant manner and add empty entries for missing keys.
			$cleaned_details=array();
			if(!empty($template_details)){ foreach($template_details as $k=>$v){

				// format according to some types
				if(isset($v['type']) && (isset($v['value']) || isset($v['default']))){
					if($v['type'] == 'currency'){
						if(isset($v['value'])){
							$v['value'] = number_format($v['value'],2,'.','');
						}else{
							$v['default'] = number_format($v['default'],2,'.','');
						}
					}
				}

				// add label
				if(substr($k,-6)=='_label'){
					// create default array
					if(!isset($cleaned_details[substr($k,0,-6)])){
						$cleaned_details[substr($k,0,-6)]['label'] = '';
						$cleaned_details[substr($k,0,-6)]['label_static'] = 1;
						$cleaned_details[substr($k,0,-6)]['value'] = '';
						$cleaned_details[substr($k,0,-6)]['value_static'] = 1;
						$cleaned_details[substr($k,0,-6)]['value_type'] = 'text';
					}

					// set label text
					if(isset($v['value']) || isset($v['default'])){
						$cleaned_details[substr($k,0,-6)]['label'] = isset($v['value']) ? $v['value']:$v['default'];
					}
					// is this dynamic?
					if(!isset($v['static'])){
						$cleaned_details[substr($k,0,-6)]['label_static'] = 0;
					}

				// add value
				}else{
					// create default array
					if(!isset($cleaned_details[$k])){
						$cleaned_details[$k]['label'] = '';
						$cleaned_details[$k]['label_static'] = 1;
						$cleaned_details[$k]['value'] = '';
						$cleaned_details[$k]['value_static'] = 1;
						$cleaned_details[$k]['value_type'] = 'text';
					}

					if(isset($v['value']) || isset($v['default'])){
						$cleaned_details[$k]['value'] = isset($v['value']) ? $v['value']:$v['default'];
						if(isset($v['type'])){$cleaned_details[$k]['value_type'] = $v['type']; }
					}
					// is this dynamic?
					if(!isset($v['static'])){
						$cleaned_details[$k]['value_static'] = 0;
					}
				}
			}}

			// return template details
			return $cleaned_details;
		}
		// }}}


		/**
		 * Get dynamic template fields
		 *
		 * Return the template fields, with data types and default values.
		 * Developer added "data-" entries are excluded.
		 *
		 * @author Thomas Smart <dev*ThomasSmart*c0m>
		 * @category Validation and Retrieval
		 * @access public
		 * @param String $template name of the template to retrieve details for
		 * @return Array pass details
		*/
		public function get_dynamic_template_fields($template) {
			// pass details are required
			if ($template == '') {
				// Print error
				$this->error('Valid template name required.',debug_backtrace());

				// Return fail
				return false;
			}

			// Query passkit for template details for the provided template name.
			// Convert to array for consistancy and cleaning
			$q = $this->pk_query('template/'.urlencode($template).'/fieldnames');
			if($q && isset($this->pk_result->{$template} )) {
				$template_details = $this->object2array($this->pk_result->{$template});
			}else{
				$template_details = array();
			}

			return $template_details;
		}
		// }}}


		/*************************************************************/
		/*	Pass Interaction										 */
		/*************************************************************/

		// {{{ template_update()
		/**
			* Update a template
			*
			* Update a template causing all issues passes for the template
			* to also be updated. Can be used max every 10 minutes.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access private
			* @param String $template Name of the template to update
			* @param Array $fields The field names with value to update
			* @param Boolean $push Push to devices or not, default yes
			* @return Boolean True on success
		*/
		public function template_update($template,$fields,$push=true) {
			// template and fields are required
			if($template == '' || empty($fields)){
				// Print error
				$this->error('Template name and fields are required for this function.',debug_backtrace());

				// Return fail
				return false;
			}

			// send update to passkit
			return $this->pk_query('template/update/'.urlencode($template).($push ? '/push/':''),$fields);
		}
		// }}}

		// {{{ pass_update()
		/**
			* Update a pass
			*
			* Update or add dynamic fields for the current pass. The URL path
			* is the same for most update actions and the fields to change can
			* be passed as a parameter array. Note that adding new fields is
			* the same as updating existing fields. Added fields will not
			* be visible by the user. Specific frequently used actions are
			* available below as their own functions. They will call this
			* generic update function with specific instructions.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access private
			* @param Array $fields The field names with value to update
			* @param Boolean $push Push to devices or not, default yes
			* @return Boolean True on success
		*/
		public function pass_update($fields,$push=true) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return fail
				return false;
			}

			// fields are required
			if(empty($fields)){
				// Print error
				$this->error('Fields are required for this function.',debug_backtrace());

				// Return fail
				return false;
			}

			// send update to passkit
			return $this->pk_query('pass/update/template/'.urlencode($this->pass_details['template_name']).'/serial/'.$this->pass_details['serial_number'].($push ? '/push/':''),$fields);
		}
		// }}}

		// {{{ pass_redeem()
		/**
			* Redeem Pass
			*
			* Redeem the pass with PassKit by setting the data-status variable in the
			* passData section. This allows us to "redeem" the pass without nuking it.
			* additional fields to update can be passed to this function. For example
			* to replace an "expire" label and date with a "redeemed" label and date.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access public
			* @param  Array $post_fields Associated array of filed name => value pairs to post with the redeem action
			* @return Boolean True on success
		*/
		public function pass_redeem($post_fields=array()) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return false
				return false;
			}

			// action
			$action = array("data-status"=>"Redeemed");

			// If there are additional fields to update merge them with the action array
			if(!empty($post_fields)){
				$action = array_merge($action, $post_fields);
			}

			// send action to passkit to set the status to redeemed
			return $this->pass_update($action);
		}
		// }}}

		// {{{ pass_reactivate()
		/**
			* Reactivate Pass
			*
			* Make a pass available again for redemption by setting the data-status
			* variable in the passData section to "Available". Additional fields can also
			* be passed to the function for resetting the pass to its original template for example.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access public
			* @param  Array $post_fields Associated array of filed name => value pairs to post with the reactivate action
			* @param  Boolean $push If true, an update will be pushed to the pass
			* @return Boolean True on success
		*/
		public function pass_reactivate($post_fields=array(),$push=true) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return false
				return false;
			}

			// action
			$action = array("data-status"=>"Available");

			// If there are additional fields to update merge them with the action array
			if(!empty($post_fields)){
				$action = array_merge($action, $post_fields);
			}

			// send action to passkit to set the status to available
			return $this->pass_update($action, $push);
		}
		// }}}

		// {{{ pass_invalidate()
		/**
			* Invalidate (Nuke) pass
			*
			* Completely nuke a pass making it no longer usable
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access public
			* @param  Array $post_fields additional fields to post with the invalidate action
			* @return Boolean True on successful invalidation
		*/
		public function pass_invalidate($post_fields=array()) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return false
				return false;
			}

			// action
			$action = array(
				"removeLocations"				=> 1,						// remove any geo location settings
				"removeBarcode"					=> 1,						// remove the barcode
				"removeRelevantDate"		=> 1,						// Remove any relevant date settings
				"data-status"						=> "Redeemed"		// set data-status to redeemed
			);

			// If there are additional fields to update merge them with the action array
			if(!empty($post_fields)){
				$action = array_merge($action, $post_fields);
			}

			// send action to passkit to invalidate the pass
			return $this->pk_query('pass/invalidate/template/'.urlencode($this->pass_details['template_name']).'/serial/'.$this->pass_details['serial_number'].'/push/',$action);
		}
		// }}}

		// {{{ pass_add_field()
		/**
			* Add Field to Pass
			*
			* Add a single new variable to a pass. These are data fields and not visible
			* to the user.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access public
			* @param String $label The name of the variable to add
			* @param String $value The value of the variable to add
			* @return Boolean True on success
		*/
		public function pass_add_field($label,$value) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return false
				return false;
			}

			return $this->pass_update(array($label=>$value));
		}
		// }}}

		// {{{ pass_add_fields()
		/**
			* Add Fields to Pass
			*
			* Add multiple variables to a pass. These are data fields and not visible
			* to the user.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Pass Interaction
			* @access public
			* @param Array $fields Array of key=>value to be added
			* @return Boolean True on success
		*/
		public function pass_add_fields($fields) {
			// pass details are required
			if(empty($this->pass_details)){
				// Print error
				$this->error('Pass details are required to be set before you can use this function. Please use the pass_validate() function to validate the Pass ID with PassKit and set pass details.',debug_backtrace());

				// Return false
				return false;
			}

			return $this->pass_update(array($fields));
		}
		// }}}






		/*************************************************************/
		/*	Helper Functions																				 */
		/*************************************************************/

		// {{{ sanitize()
		/**
			* Sanitize String
			*
			* Strips non alpha-numerics from given string. / and . are also allowed.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Helper Functions
			* @access private
			* @param String $var Variable to sanitize
			* @return String Sanitized variable
		*/
		private function sanitize($var) {
			// sanitize account
			return trim(preg_replace('/[^\w\.\/]/','',$var));
		}
		// }}}

		// {{{ object2array()
		/**
			* Object to Array conversion
			*
			* Converts an object to an array for easier and consistant access
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Helper Functions
			* @access private
			* @param Object $object Object to convert
			* @return Array
		*/
		private function object2array($object) {
			return json_decode(json_encode($object),true);
		}
		// }}}

		// {{{ error()
		/**
			* Output Error
			*
			* Error reporting function that will output a styled debug of the
			* class variable "debug" is enabled.
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @category Helper Functions
			* @access public
			* @param String $error Error Message to display
			* @param Array $backtrace The backtrace from point of error
			* @return false
		*/
		private function error($error,$backtrace) {
			if($this->debug){
				echo '<div style="float:left;width:auto; padding:10px; margin:10px; margin-top:40px; border:dashed 1px #444; background-color:#EEF0F4;">';
				echo '<strong>Error: </strong> '.$error.'<br /><br /><strong>Backtrace</strong><br /><pre>'.print_r($backtrace,true).'</pre>';
				echo '</div>';
			}
			return false;
		}
		// }}}

		// {{{ detect_passbook()
		/**
		  * Detect Passbook capable browsers
		  *
		  * Sniffs the browser useragent string to determine if the browser can process .pkpass files.
		  * Note that this funciton will need maintaining as browser compatibility evolves.
		  *
		  * @author Thomas Smart <dev*ThomasSmart*c0m>
		  * @category Helper Functions
		  * @access private
		  * @param String $agent_string User agent string to check, if null the SERVER var will be used
		  * @param Integar $ver	Maximum major version number to consider for Safari on Apple
		  * @param Integar $subver Maximum minor version number to consider for Safari on Apple
		  * @return Boolean True if a Passbook capable browser is found
		*/
		public function detect_passbook($agent_string = null, $ver = 9, $subver = 9){

			// retrieve agent string if available
			$agent_string = ($agent_string ? $agent_string : (isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : false));

			// iDevices
			if(strpos($agent_string, 'iPhone; CPU iPhone OS 6') || strpos($agent_string,  'iPod; CPU iPhone OS 6')){
				return true;
			}

			// safari on apple
			if(strpos($agent_string, 'Safari') && !strpos($agent_string, 'Chrom')){
				for($i = 8; $i <= $ver; $i++){
					for($ii = 2; $ii <= $ver; $ii++){
						$ua_string = "Mac OS X 10_".$i."_".$ii;
						if(strpos($agent_string, $ua_string) !== false){
							return true;
						}
					}
				}
			}

			// not found
			return false;
		}
		// }}}

		// {{{ __destruct()
		/**
			* __destruct
			*
			* @author Thomas Smart <dev*ThomasSmart*c0m>
			* @access public
			* @return void
		*/
		public function __destruct(){

		}
		// }}}
	}