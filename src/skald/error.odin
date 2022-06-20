package skald



//= Imports
import "core:fmt"

//= Constants

//= Global Variables

//= Structures

//= Enumerations

//= Procedures

// Optional Error logging
output_error :: proc(error: ErrorCode) -> bool {

	#partial switch error {
		case .init_failed_check:
			fmt.printf("[ERROR][LOW]SKALD - 0x00 | Skald core not initialized.\n");
		case .already_init_skald:
			fmt.printf("[ERROR][LOW]SKALD - 0x02 | Attempted to initialize Skald while already initialized.\n");
		case .internal_error:
			fmt.printf("[ERROR][HIG]SKALD - 0x03 | Internal error with either Skald or Raylib.\n");
		case .def_texture_missing:
			fmt.printf("[ERROR][MID]SKALD - 0x04 | Default textbox texture missing.\n");
		case .def_cursor_missing:
			fmt.printf("[ERROR][MID]SKALD - 0x05 | Default cursor texture missing.\n");
		case .def_font_missing:
			fmt.printf("[ERROR][MID]SKALD - 0x06 | Default font missing.\n");
		case .closing_oob:
			fmt.printf("[ERROR][HIG]SKALD - 0x07 | Attempted to close a textbox out of bounds of list.\n")

	//	case .template:
	//		fmt.printf("[ERROR][]SKALD - ");
	}

	return int(error) != 0;
}

// Internal checks
@(private)
init_check :: proc() -> ErrorCode {
	if textboxCoreData == nil do return .init_failed_check;

	if textboxCoreData.defaultTexture == {} do return .def_texture_missing;
	if textboxCoreData.defaultCursor  == {} do return .def_cursor_missing;
	if textboxCoreData.defaultFont    == {} do return .def_font_missing;

	return .none;
}