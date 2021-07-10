module pusher

import crypto.md5
import crypto.hmac
import crypto.sha256
import net.http
import json
import time

pub struct Client {
pub mut:
	app_id  string
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

// prepare_request_url prepares the appropriate url for use in contactint the API
fn prepare_request_url() ?string {
	return error('not implemented')
}

struct EventPayload {
	name     string
	data     string
	channels []string
}

// trigger publishes an event on one or multiple channels with data as the payload
pub fn (c Client) trigger(channels []string, event string, data map[string]string) ?http.Response {
	c.is_valid() ?

	payload := EventPayload{
		name: event
		channels: channels
		data: json.encode(data)
	}

	body := json.encode(payload)
	body_md5_hash := md5.hexhash(body)
	timestamp := time.now().unix_time()

	signature := hmac.new(c.secret.bytes(), 'POST\n/apps/$c.app_id/events\nauth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&body_md5=$body_md5_hash'.bytes(),
		sha256.sum256, sha256.block_size)

	url := 'https://api-${c.cluster}.pusher.com/apps/$c.app_id/events?auth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&body_md5=$body_md5_hash&auth_signature=$signature.hex()'

	mut request := http.Request{
		method: .post
		url: url
	}

	request.add_header(.content_type, 'application/json')
	request.data = body
	return request.do()
}

// An Event encapsulates the details of one Event that can be triggered.
pub struct Event {
pub mut:
	name    string            [required]
	data    map[string]string [required]
	channel string            [required]
}

// A BatchEvent is an internal representation of an event to be used in a batch request
struct BatchEvent {
	name string
	data string
	channel string
}

fn create_batch_events(events []Event) []BatchEvent {
	mut batch_events := []BatchEvent{}
	for e in events {
		batch_events << BatchEvent{
			name: e.name
			channel: e.channel
			data: json.encode(e.data)
		}
	}
	return batch_events
}

// trigger_batch lets you trigger mulitple Events in one call.
// Note that you are limited to a maximum of 10 events per call
pub fn (c Client) trigger_batch(batch []Event) ?http.Response {
	c.is_valid() ?
	payload := create_batch_events(batch)
	body := json.encode(map{"batch": payload})
	body_md5_hash := md5.hexhash(body)
	timestamp := time.now().unix_time()

	signature := hmac.new(c.secret.bytes(), 'POST\n/apps/$c.app_id/batch_events\nauth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&body_md5=$body_md5_hash'.bytes(),
		sha256.sum256, sha256.block_size)

	url := 'https://api-${c.cluster}.pusher.com/apps/$c.app_id/batch_events?auth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&body_md5=$body_md5_hash&auth_signature=$signature.hex()'

	mut request := http.Request{
		method: .post
		url: url
	}

	request.add_header(.content_type, 'application/json')
	request.data = body
	return request.do()
}


pub enum ChannelAttribute {
	user_count
}

pub enum ChannelFilter {
	private
	presence
}

// channels returns a list of all the channels in an application.
// It allows you to fetch a hash of occupied channels (optionally filtered by prefix),
// and optionally one or more attributes for each channel.
pub fn (c Client) channels(prefix string, attrs string) ?http.Response {
	c.is_valid() ?

	timestamp := time.now().unix_time()
	signature := hmac.new(
		c.secret.bytes(),
		'GET\n/apps/$c.app_id/channels\nauth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&filter_by_prefix=$prefix&info=$attrs'.bytes(),
		sha256.sum256, sha256.block_size
	)

	url := 'https://api-${c.cluster}.pusher.com/apps/$c.app_id/channels?auth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&auth_signature=${signature.hex()}&filter_by_prefix=$prefix&info=$attrs'

	mut request := http.Request{
		method: .get
		url: url
	}

	return request.do()
}

// channel allows you to get the state of a single channel
pub fn (c Client) channel(channel string, attrs string) ?http.Response {
	c.is_valid() ?

	timestamp := time.now().unix_time()
	signature := hmac.new(
		c.secret.bytes(),
		'GET\n/apps/$c.app_id/channels/$channel\nauth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&info=$attrs'.bytes(),
		sha256.sum256, sha256.block_size
	)

	url := 'https://api-${c.cluster}.pusher.com/apps/$c.app_id/channels/$channel?auth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&auth_signature=${signature.hex()}&info=$attrs'

	mut request := http.Request{
		method: .get
		url: url
	}

	return request.do()
}

// get_channel_users returns a list of users in a presence-channel by passing to this
// method the channel name.
pub fn (c Client) get_channel_users(channel string) ?http.Response {
	// TODO: channel must be prefixed with 'presence-'
	c.is_valid() ?

	timestamp := time.now().unix_time()
	signature := hmac.new(
		c.secret.bytes(),
		'GET\n/apps/$c.app_id/channels/$channel/users\nauth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0'.bytes(),
		sha256.sum256, sha256.block_size
	)

	url := 'https://api-${c.cluster}.pusher.com/apps/$c.app_id/channels/$channel/users?auth_key=$c.key&auth_timestamp=$timestamp&auth_version=1.0&auth_signature=${signature.hex()}'

	mut request := http.Request{
		method: .get
		url: url
	}

	return request.do()
}