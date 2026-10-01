import gleam/bit_array
import gleeunit/should

@external(erlang, "bbs_gzip_ffi", "gzip_compress")
fn gzip_compress(raw: BitArray) -> Result(BitArray, String)

pub fn qdeflate_extreme_compression_test() {
  let sample_text =
    "{\"name\":\"Q-Deflate SaaS\",\"version\":\"1.0.0\",\"desc\":\"Extreme entropy compression with zero client friction\",\"features\":[\"RFC 1951 compliant\",\"0-second decompression\",\"AWS Egress cut by 20-30%\"],\"repeat\":\"Extreme entropy compression with zero client friction\"}"
  let raw = bit_array.from_string(sample_text)
  let raw_size = bit_array.byte_size(raw)

  case gzip_compress(raw) {
    Ok(compressed) -> {
      let comp_size = bit_array.byte_size(compressed)
      // 圧縮バイナリが生成され、かつ生データより遥かに小さいことを検証
      should.be_true(comp_size < raw_size)
      should.be_true(comp_size > 0)
    }
    Error(err) -> {
      panic as err
    }
  }
}
