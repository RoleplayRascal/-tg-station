#define IC_INPUT "input"
#define IC_OUTPUT "output"
#define IC_ACTIVATOR "activator"

// Pin functionality.
#define DATA_CHANNEL "data channel"
#define PULSE_CHANNEL "pulse channel"

// Methods of obtaining a circuit.
#define IC_SPAWN_DEFAULT			1 // If the circuit comes in the default circuit box and able to be printed in the IC printer.
#define IC_SPAWN_RESEARCH 			2 // If the circuit design will be available in the IC printer after upgrading it.

// Displayed along with the pin name to show what type of pin it is.
#define IC_FORMAT_ANY			"\<ANY\>"
#define IC_FORMAT_STRING		"\<TEXT\>"
#define IC_FORMAT_CHAR			"\<CHAR\>"
#define IC_FORMAT_COLOR			"\<COLOR\>"
#define IC_FORMAT_NUMBER		"\<NUM\>"
#define IC_FORMAT_DIR			"\<DIR\>"
#define IC_FORMAT_BOOLEAN		"\<BOOL\>"
#define IC_FORMAT_REF			"\<REF\>"
#define IC_FORMAT_LIST			"\<LIST\>"
#define IC_FORMAT_ANY			"\<ANY\>"
#define IC_FORMAT_PULSE			"\<PULSE\>"

// Used inside input/output list to tell the constructor what pin to make.
#define IC_PINTYPE_ANY				/datum/integrated_io
#define IC_PINTYPE_STRING			/datum/integrated_io/string
#define IC_PINTYPE_CHAR				/datum/integrated_io/char
#define IC_PINTYPE_COLOR			/datum/integrated_io/color
#define IC_PINTYPE_NUMBER			/datum/integrated_io/number
#define IC_PINTYPE_DIR				/datum/integrated_io/dir
#define IC_PINTYPE_BOOLEAN			/datum/integrated_io/boolean
#define IC_PINTYPE_REF				/datum/integrated_io/ref
#define IC_PINTYPE_LIST				/datum/integrated_io/list

#define IC_PINTYPE_PULSE_IN			/datum/integrated_io/activate
#define IC_PINTYPE_PULSE_OUT		/datum/integrated_io/activate/out

// Data limits.
#define IC_MAX_LIST_LENGTH			200

//Some colors

#define COLOR_WHITE            "#ffffff"
#define COLOR_SILVER           "#c0c0c0"
#define COLOR_GRAY             "#808080"
#define COLOR_FLOORTILE_GRAY   "#8D8B8B"
#define COLOR_BLACK            "#000000"
#define COLOR_RED              "#ff0000"
#define COLOR_RED_LIGHT        "#b00000"
#define COLOR_MAROON           "#800000"
#define COLOR_YELLOW           "#ffff00"
#define COLOR_AMBER            "#ffbf00"
#define COLOR_OLIVE            "#808000"
#define COLOR_LIME             "#00ff00"
#define COLOR_GREEN            "#008000"
#define COLOR_CYAN             "#00ffff"
#define COLOR_TEAL             "#008080"
#define COLOR_BLUE             "#0000ff"
#define COLOR_BLUE_LIGHT       "#33ccff"
#define COLOR_NAVY             "#000080"
#define COLOR_PINK             "#ff00ff"
#define COLOR_PURPLE           "#800080"
#define COLOR_ORANGE           "#ff9900"
#define COLOR_LUMINOL          "#66ffff"
#define COLOR_BEIGE            "#ceb689"
#define COLOR_BLUE_GRAY        "#6a97b0"
#define COLOR_BROWN            "#b19664"
#define COLOR_DARK_BROWN       "#917448"
#define COLOR_DARK_ORANGE      "#b95a00"
#define COLOR_GREEN_GRAY       "#8daf6a"
#define COLOR_RED_GRAY         "#aa5f61"
#define COLOR_PALE_BLUE_GRAY   "#8bbbd5"
#define COLOR_PALE_GREEN_GRAY  "#aed18b"
#define COLOR_PALE_RED_GRAY    "#cc9090"
#define COLOR_PALE_PURPLE_GRAY "#bda2ba"
#define COLOR_PURPLE_GRAY      "#a2819e"
#define COLOR_SUN              "#ec8b2f"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK   "#545454"
#define COLOR_ASSEMBLY_BGRAY   "#9497AB"
#define COLOR_ASSEMBLY_WHITE   "#E2E2E2"
#define COLOR_ASSEMBLY_RED     "#CC4242"
#define COLOR_ASSEMBLY_ORANGE  "#E39751"
#define COLOR_ASSEMBLY_BEIGE   "#AF9366"
#define COLOR_ASSEMBLY_BROWN   "#97670E"
#define COLOR_ASSEMBLY_GOLD    "#AA9100"
#define COLOR_ASSEMBLY_YELLOW  "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA  "#999875"
#define COLOR_ASSEMBLY_LGREEN  "#789876"
#define COLOR_ASSEMBLY_GREEN   "#44843C"
#define COLOR_ASSEMBLY_LBLUE   "#5D99BE"
#define COLOR_ASSEMBLY_BLUE    "#38559E"
#define COLOR_ASSEMBLY_PURPLE  "#6F6192"

var/global/list/alphabet_uppercase = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")

var/list/all_integrated_circuits = list()

/proc/initialize_integrated_circuits_list()
	for(var/thing in typesof(/obj/item/integrated_circuit))
		all_integrated_circuits += new thing()

/obj/item/integrated_circuit
	name = "integrated circuit"
	desc = "It's a tiny chip!  This one doesn't seem to do much, however."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "template"
	w_class = 1
	var/obj/item/device/electronic_assembly/assembly = null // Reference to the assembly holding this circuit, if any.
	var/extended_desc = null
	var/list/inputs = list()
	var/list/inputs_default = list()			// Assoc list which will fill a pin with data upon creation.  e.g. "2" = 0 will set input pin 2 to equal 0 instead of null.
	var/list/outputs = list()
	var/list/outputs_default = list()		// Ditto, for output.
	var/list/activators = list()
	var/next_use = 0 //Uses world.time
	var/complexity = 1 				//This acts as a limitation on building machines, more resource-intensive components cost more 'space'.
	var/size = null					//This acts as a limitation on building machines, bigger components cost more 'space'. -1 for size 0
	var/cooldown_per_use = 1 SECONDS // Circuits are limited in how many times they can be work()'d by this variable.
	var/power_draw_per_use = 0 		// How much power is drawn when work()'d.
	var/power_draw_idle = 0			// How much power is drawn when doing nothing.
	var/spawn_flags = null			// Used for world initializing, see the #defines above.
	var/category_text = "NO CATEGORY THIS IS A BUG"	// To show up on circuit printer, and perhaps other places.
	var/removable = TRUE 			// Determines if a circuit is removable from the assembly.
	var/displayed_name = ""
	var/allow_multitool = 1			// Allows additional multitool functionality
									// Used as a global var, (Do not set manually in children).
