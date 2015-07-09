% Intro to Rust: Writing a crackme

Spenser Reinhardt

DC612 - July 9, 2015

# What is Rust

Rust is a fairly new systems programming language focused on safety and speed.

```rust
fn main() {
    println!("Hello, world!");
}
```

```norust
> Hello, world!
```

# History

* Started as a personal project in 2006 by Graydon Hoare
* First compiler written in OCaml
* Mozilla took over the project 3 years later
* Compiler rewritten in Rust itself in 2010

# Variable Creation and Assignment

```rust
let var = "abc";
var.push("def");
```

# Conditional Statements

```rust
if val = 1 {
    do_something();
} else if val = b {
    do_something_else();
} else {
    do_nothing();
}
```

# Match Statements

```rust
match val {
    1 => do_something(),
    a => do_something_else(),
    _ => do_nothing(),
};
```

# Option Types

```rust
let result = match Option<T> {
    Some(val) => val,
    None => default,
};
```

# Result Types

```rust
let var = match Result<T,E> {
    Ok(t) => t,
    Err(e) => e,
};
```

# Function Declarations

```rust
fn test(a,b) {
    if a < b {
        return a;
    }
    a + b
}
```

# Crackme Objectives

* Reverse engineering challenge
* Difficult but not impossible
* Little to no hints in binary
* Relative to audiance interests

# main.rs

```rust
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
```

# Capturing Arguments

```rust
pub fn get_key_from_args() -> Result<String,KeyErr> {

	let args: Vec<String> = env::args().collect();

	match &args[..] {
		[ref name] => {
			println!("Usage: {} figure it out", name);
			Err(KeyErr::InvalidArgs)
		},
		[_, ref string] => {
			match string.parse() {
				Ok(s) => Ok(s),
				Err(_) => Err(KeyErr::InputParse),
			}
		},
		_ => {
			println!("Usage: this shouldnt be happening!");
			Err(KeyErr::UnknownError)
		},
	}
```

# Separating the Key

```rust
pub fn get_key_segments(key: &str) -> KeyRst {

	//validate length: 5 char x 3 segments + 2 hyphens = 17
	if key.len() != KEYLEN {
		return Err(KeyErr::InvalidLength);
	}

	let mut segments = Vec::new();
	for seg in key.split("-") {
		segments.push(seg.to_string());
	};

	Ok(segments)
}
```

# Error Handling

```rust
#[allow(dead_code)]
pub enum KeyErr {
	InvalidArgs,
	InputParse,
	InvalidLength,
	InvalidFormat,
	S1Err,
	S2Err,
	S3Err,
	UnknownError,
}

pub fn handle_errors(err: KeyErr) {

	match err {
		KeyErr::InvalidArgs => println!("Improper arguments provided"),
		KeyErr::InputParse => println!("Failed to parse key"),
		KeyErr::InvalidLength => println!("Invalid key length"),
		KeyErr::InvalidFormat => println!("Invalid key format"),
		KeyErr::S1Err => println!("Segment 1 error"),
		KeyErr::S2Err => println!("Segment 2 error"),
		KeyErr::S3Err => println!("Segment 3 error"),
		KeyErr::UnknownError => panic!("An unknown error occured"),
	};
}
```

# Segment 1

```rust
pub fn check_segment1(key: &Vec<String>) -> KeyRst {

	// get segment 0 of the input key
	let keyslice = match key.get(0) {
		Some(k) => k,
		None => return Err(KeyErr::S1Err),
	};

	// convert segment into u64 value
	let value = match u64::from_str_radix(keyslice, 10) {
		Ok(v) => v,
		Err(_) => return Err(KeyErr::S1Err),
	};

	// few conditional checks on value
	if 50000 > value {
		return Err(KeyErr::S1Err);
	};

	if value % 5 != 0 {
		return Err(KeyErr::S1Err);
	};

	let keyslice: Vec<u8> = keyslice.bytes().collect();	// convert each char into utf-8 bytes,
	let modvec = vec![2,8,-4,0,-1];						// create offset vector
	let mut rst: Vec<u8> = Vec::with_capacity(5);		// create new segment storage
	for i in 0..modvec.len() {							// for the size of offset vector
		let t = match keyslice.get(i) {					// get each value of keyslice bytes
			Some(v) => v,
			None => return Err(KeyErr::S1Err),
		};
		rst.push(((*t as i8) - modvec[i]) as u8);						// result[i] = segment[i] - modvec[i]
	};

	// convert rst from Vec<u8> to &str
	let rst = match str::from_utf8(&rst) {
		Ok(k) => k,
		Err(_) => return Err(KeyErr::S1Err),
	};
	// clone and mod original key for return
	let mut ret = key.clone();
	ret[0] = rst.to_string();
	Ok(ret)
}
```

# Segment 2

```rust
pub fn check_segment2(key: &Vec<String>, modkey: &mut Vec<String>) -> KeyRstN {

	let k1: Vec<u8> = key[1].bytes().collect();			// collect segment 2 of key as Vec<u8>
	let off: Vec<u8> = vec![6u8,16u8,95u8,85u8,87u8];	// create offset Vec<u8>
	let mut rst: Vec<u8> = Vec::with_capacity(5);			// create storage Vec<u8>
	for i in 0..off.len() {									// for size of offset
		let a = match k1.get(i) {							// capture value from k1[i]
			Some(c) => c,
			None => return Err(KeyErr::S2Err),
		};
		let b = match off.get(i) {							// capture value from off[i]
			Some(c) => c,
			None => return Err(KeyErr::S2Err),
		};
		rst.push(a^b);									// rst[i] = k1[i] ^ off[i]
	};

	let fin = match String::from_utf8(rst) {
		Ok(k) => k,
		Err(_) => return Err(KeyErr::S2Err),
	};
	modkey[1] = fin;

	Ok(())
}
```

# Segment 3

```rust
pub fn check_segment3(key: &Vec<String>, modkey:&mut Vec<String>) -> KeyRstN {

	let mk: &Vec<String> = &modkey.clone();
	let mk0 = match mk.get(0) {
		Some(s) => s,
		None => return Err(KeyErr::S3Err),
	};
	// get segment 2 of input key
	let key2 = match key.get(1) {
		Some(v) => v,
		None => return Err(KeyErr::S3Err),
	};
	let k2b: Vec<u8> = key2.bytes().collect();		// transform to byte vector
	let mk0b: Vec<u8> = mk0.bytes().collect();		// transform mod_key[0] to byte vector
	let mut rst: Vec<i8> = Vec::with_capacity(5);	// create storage vector

	for i in 0..k2b.len() {							// for length of segment 2 of input
		let a = match k2b.get(i) {					// get each char
			Some(v) => *v as i8,
			None => return Err(KeyErr::S3Err),
		};
		let b = match mk0b.get(i) {					// get each char
			Some(v) => *v as i8,
			None => return Err(KeyErr::S3Err),
		};
		rst.push(b-a);								// rst[i] = mk0b[i] - k2b[i]
	};

	let off: Vec<i16> = vec![130i16, 95i16, 80i16, 33i16, 29i16];	// create offset vector
	let mut ret: Vec<u8> = Vec::with_capacity(5);		// create storage vector

	for i in 0.. rst.len() {						// for length of rst
		let a = match rst.get(i) {					// capture rst[i]
			Some(v) => v,
			None => return Err(KeyErr::S3Err),
		};
		let b = match off.get(i) {					// capture off[i]
			Some(v) => v,
			None => return Err(KeyErr::S3Err),
		};
		ret.push(((*a as i16)+b) as u8);						// rst[i] = rst[i] + off[i]
	};

	let fin = match String::from_utf8(ret) {
		Ok(v) => v,
		Err(_) => return Err(KeyErr::S3Err),
	};
	modkey[2] = fin;
	Ok(())
}
```

# Final Validation

```rust
pub fn check_final(key: &Vec<String>) -> bool {
	let mut string = String::new();
	for val in key.iter() {
		string = format!("{}{}-", string, val);
	}
	let len = string.len()-1;
	string.truncate(len);
	let bytes: Vec<u8> = string.bytes().collect();
	let digest = compute(bytes.as_slice());
	let mut string: Vec<u8> = Vec::new();
	string.push_all(&digest);
	let md5 = match String::from_utf8(string) {
		Ok(s) => s,
		Err(e) => {
			println!("{}", e);
			return false;
		},
	};
	println!("{}", md5);
	true
}
```

# Questions

Spenser Reinhardt

@c0mmiebstrd
