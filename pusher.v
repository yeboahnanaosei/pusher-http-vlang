module pusher

import crypto.md5
import crypto.hmac
import crypto.sha256
import net.http
import json
import time

pub struct Client {
pub mut:
	app_id      string
	key     string
	secret  string
	cluster string = 'mt1'
}

// is_valid checks to make sure that the client has all required fields set
fn (c Client) is_valid() ?bool {
	if c.app_id == '' {
		return error('no id supplied')
	}
	if c.key == '' {
		return error('no key supplied')
	}
	if c.secret == '' {
		return error('no secret supplied')
	}
	return true
}



// trigger publishes an event on the channel with data as the payload
pub fn (c Client) trigger(channel string, event string, data map[string]string) ?http.Response {
	c.is_valid() ?

	mut payload := map[string]string{}
	payload['name'] = event
	payload['channel'] = channel
	payload['data'] = json.encode(data)

	body := json.encode(payload)
	body_md5_hash := md5.hexhash(body)
	timestamp := time.now().unix_time()

	signature := hmac.new(
		c.secret.bytes(),
		"POST\n/apps/${c.app_id}/events\nauth_key=${c.key}&auth_timestamp=${timestamp}&auth_version=1.0&body_md5=${body_md5_hash}".bytes(),
		sha256.sum256,
		sha256.block_size
	)

	url := 'https://api-${c.cluster}.pusher.com/apps/${c.app_id}/events?auth_key=${c.key}&auth_timestamp=${timestamp}&auth_version=1.0&body_md5=${body_md5_hash}&auth_signature=${signature.hex()}'

	mut request := http.Request {
		method: .post,
		url: url
	}

	request.add_header(.content_type, "application/json")
	request.data = body
	return request.do()
}

// trigger_multi lets you publish one event on multiple channels
pub fn (c Client) trigger_multi(channels []string, event string, data map[string]any){

}
