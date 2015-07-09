#![feature(slice_patterns, convert, vec_push_all)]
extern crate md5;
mod keys;
use keys::*;

fn main() {

	// capture arguments
	let key = match get_key_from_args() {
		Ok(k) => k,
		Err(why) => {
			handle_errors(why);
			return;
		},
	};

	// separate key into segments xxxxx-xxxxx-xxxxx
	let segments = match get_key_segments(key.as_ref()) {
		Ok(s) => s,
		Err(why) => {
			handle_errors(why);
			return;
		},
	};
	// check segment1 and create modified key
	let mut mod_key = match check_segment1(segments.as_ref()) {
		Ok(s) => s,
		Err(why) => {
			handle_errors(why);
			return;
		},
	};

	// check segment 2 and store result in seg
	let _ = match check_segment2(segments.as_ref(), &mut mod_key) {
		Ok(_) => {},
		Err(why) => {
			handle_errors(why);
			return;
		},
	};

	// check segment 3
	let _ = match check_segment3(segments.as_ref(), &mut mod_key) {
		Ok(_) => {},
		Err(why) => {
			handle_errors(why);
			return;
		},
	};

	if check_final(mod_key.as_ref()) {
		print_key(&segments);
		print_key(&mod_key);
	} else {
		println!("You failed to enter the correct key");
	}

}
