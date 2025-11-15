extends Node
class_name DatabaseLoader

const HEADER := "RPGDB4"
const VERSION := 1
const KEY := "ASTRAL_LEGACY_KEY"

var data_sets: Dictionary = {}

func load_database(path: String) -> bool:
    data_sets.clear()
    var file_bytes := FileAccess.get_file_as_bytes(path)
    if file_bytes.is_empty():
        push_error("Database file missing: %s" % path)
        return false
    if file_bytes.size() < HEADER.length() + 9:
        push_error("Database file too small")
        return false
    var header_bytes := file_bytes.slice(0, HEADER.length())
    if header_bytes.get_string_from_utf8() != HEADER:
        push_error("Invalid database header")
        return false
    var version := file_bytes[HEADER.length()]
    if version != VERSION:
        push_warning("Database version %d differs from expected %d" % [version, VERSION])
    var offset := HEADER.length() + 1
    var unpack := file_bytes.decode_u32(offset, true)
    offset += 4
    var compressed_size := file_bytes.decode_u32(offset, true)
    offset += 4
    if offset + compressed_size > file_bytes.size():
        push_error("Corrupted database payload")
        return false
    var encrypted := file_bytes.slice(offset, offset + compressed_size)
    var key_bytes := KEY.to_utf8_buffer()
    var decrypted := PackedByteArray()
    decrypted.resize(encrypted.size())
    for i in encrypted.size():
        decrypted[i] = encrypted[i] ^ key_bytes[i % key_bytes.size()]
    var decompressed := Compression.decompress(decrypted, unpack, Compression.MODE_ZLIB)
    if decompressed.is_empty():
        push_error("Failed to decompress database")
        return false
    var json_text := decompressed.get_string_from_utf8()
    var parsed := JSON.parse_string(json_text)
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Database root is invalid")
        return false
    data_sets = parsed
    return true

func get_section(name: String) -> Variant:
    if not data_sets.has(name):
        push_warning("Section %s not found in database" % name)
        return null
    return data_sets[name]

func get_available_databases() -> Array:
    var dbs: Array = []
    var dir := DirAccess.open("res://")
    if dir:
        dir.list_dir_begin()
        var entry := dir.get_next()
        while entry != "":
            if entry.ends_with(".dl"):
                dbs.append(entry)
            entry = dir.get_next()
        dir.list_dir_end()
    return dbs
