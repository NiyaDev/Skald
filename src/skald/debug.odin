package skald
//=-------------------=//
// Written: 2022/06/13 //
// Edited:  2022/06/13 //
// Version:   0.01.0   //
//=-------------------=//



//= Imports
import fmt "core:fmt"

//= Global Variables

//= Constants

//= Enumerations
ErrorCode :: enum {
	none,
	init_failed_check, already_init_skald,
	internal_error,
	def_texture_missing, def_cursor_missing, def_font_missing,
	closing_oob};

//= Structures

//= Procedures

//- output error
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