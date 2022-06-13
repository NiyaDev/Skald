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
	def_texture_missing, def_cursor_missing, def_font_missing, };

//= Structures

//= Procedures

//- output error
output_error :: proc(error: ErrorCode) {

	#partial switch error {
		case .init_failed_check:
			fmt.printf("[ERROR][LOW]SKALD - Skald core not initialized.");
		case .already_init_skald:
			fmt.printf("[ERROR][LOW]SKALD - Attempted to initialize Skald while already initialized.");
	}
}