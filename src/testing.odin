package main
///=-------------------=///
//  Written: 2022/05/20  //
//  Edited:  2022/06/13  //
///=-------------------=///



import "core:fmt"
import "core:strings"

import ray "raylib"
import txt_old "textbox_old"
import "skald"


test_proc1 :: proc() { fmt.printf("fuck1\n"); }
test_proc2 :: proc() { fmt.printf("fuck2\n"); }

//= Main
main :: proc() {

	{ // Initialization
		ray.init_window(1280, 720, "Skald Testing");
		ray.set_target_fps(60);
	}

//	img: ray.Image = ray.load_image("data/skald/textbox.png");
//	tex: ray.Texture = ray.load_texture_from_image(img);
//	ray.unload_image(img);
//
//	npat: ray.N_Patch_Info = {};
//	npat.source = ray.Rectangle{0,0,48,48};
//	npat.left   = 16;
//	npat.top    = 16;
//	npat.right  = 16;
//	npat.bottom = 16;
//	npat.layout = i32(ray.N_Patch_Layout.NPATCH_NINE_PATCH);
//
//	test := txt_old.init_textbox(texture=tex,npatch=npat);
//	fmt.printf("%i\n", test);

//	text: [dynamic]string = make([dynamic]string);
//	append(&text, "Fuck me up and down\nFucking shit\nholy cow, man.", "Fuck me sideways and frontways", "I wanna die bad.");
//	test  = txt_old.create_textbox(position={0,500},size={400,200}, text=text);
//	fmt.printf("%i\n", test);

//	text:    [dynamic]string          = make([dynamic]string);
//	choices: [dynamic]txt_old.MenuOptions = make([dynamic]txt_old.MenuOptions);
//	append(&text, "Make your choice...");
//	option1: txt_old.MenuOptions = {text="Choice1",effect=test_proc1};
//	option2: txt_old.MenuOptions = {text="Choice2",effect=test_proc2};
//	append(&choices, option1, option2);
//	test = txt_old.create_menu(position={0,500},size={600,200}, text=text, options=choices);
//	fmt.printf("%i\n", test);

	res := skald.init_skald();
	if res != .none do return;


	text: [dynamic]string;
	append(&text, "Fuck me?", "Fuck you, motherfucker!");
	skald.create_textbox(textDynamic=text);


	for !ray.window_should_close() {
		// Updating
		{
			skald.update_textboxes();
			//txt_old.update_textboxes();
		}

		// Drawing
		{
			ray.begin_drawing();
				ray.clear_background(ray.RAYWHITE);
					
	//				txt_old.draw_textboxes();
					skald.draw_textboxes();

					ray.draw_fps((8 * 3), (8 * 5));
			ray.end_drawing();
		}
	}

	res = skald.free_skald();
	if res != .none do return;

	ray.close_window();
}
