module Data exposing (get)


get : String -> String
get docName =
    case docName of
        "manual" ->
            manual

        "notes" ->
            notes

        "test" ->
            test

        "announcement" ->
            announcement

        _ ->
            "No such document"


testData =
    """
[spreadsheet 

[row 100.0, 1.1, row * 0 1]

[row 120.0, 1.4 ,row * 0 1]

[row 140.0, 0.9 ,row * 0 1]

[row -, col sum 0 2, col sum 0 2]

]
"""


exp =
    """[i A]

[i B

[i C]
"""


manual =
    """







[macro [ds [fontRGB |0, 0, 200| ]]]

[i [code This document is a draft-in-progress of a manual for CaYaTeX]]

[title CaYaTeX Manual]

[tableofcontents]

# Standard Elements



## Text

[def | bold; b |
Render text as bold, e.g, [c raw#[bold Bold!]#] renders as [ds [bold Bold!]] Short form: [c raw#[b Bold!]#] .
]

[def | italic; i |
Render text as italic, e.g, [c raw#[italic Italic!]#] renders as [ds [italic Italic!]] Short form: [c raw#[i Italic!]#] .
]

[def | fontRGB | Render text in color with given RGB values, e.g., [c raw#[fontRGB |214, 11, 184| This is a test!]#] renders as
[fontRGB |214, 11, 184| This is a test!]

]


[def | highlight |
Highlight the text, e.g, [c raw#[highlight This is important!]#] renders as [ds [highlight This is important!]].
]

[def | link |
Make a hyperlink.  For example, the text, e.g, [c raw#[link http://nytimes.com]#] renders as [ds[link http://nytimes.com]].  One can also specify the link text, e.g., [c raw#[link | New York Times | http://nytimes.com]#] renders as [ds[link | New York Times | http://nytimes.com]].
]

[def | highlightRGB |
Highlight the text with a given color, e.g, [c raw# [highlightRGB | 255, 200, 200 | This is important!]#] renders as [ds [highlightRGB | 255, 200, 200 | This is important!]].
]

## Code

[def | code; c|
Render text in-line as code, e.g, [c raw#[code a <- b]#] renders as
[ds [code a <- b]] Short form: [c raw#[c a <- b]#] .
]

[def |  codeblock; cb |
Render text as displayed code, e.g, [c raw#[codeblock a <- b]#] renders as

[ds [codeblock a <- b]]

Short form: [c raw#[c a <- b]#] .
]


## Mathematics

[def | math; m |
Render math in-line, e.g, [c raw#[math a^2 + b^2 = c^2]#] renders as
[ds [math a^2 + b^2 = c^2]] Short form: [c raw#[m a^2 + b^2 = c^2]#] .
]

[def |  mathblock; mb |
Render math as centered block, e.g, [c raw#[mathblock \\int_0^1 x^n dx = \\frac{1}{n+1}]#] renders as

[mathblock \\int_0^1 x^n dx = \\frac{1}{n+1}]

Short form: [c raw#[mb \\int_0^1 x^n dx = \\frac{1}{n+1}]#] .
]


## Structure

[def | title | Construct a document title, e.g. as [c raw#[title Tales of Yore]#] ].

[def | tableofcontents |
Render a numbered table of contents as displayed above.]

[def | section; section1; section2; ... |
Render a numbered section heading as you see here.  For example,
[c raw#[section2 Structure]#] produces the heading for this section.  It is a level two heading and therefore is labeled with two numbers. [c section] is a synonym for [c section1], which produces a level 1 section heading.

]

section
section1
section2
section3
section4
section5
section6

##  Format

[def | center | Center the body of the element [c raw#[center BODY]#]].

[def | indent | Indent the body of the element [c raw#[indent BODY]#]].

[def | poetry | Format the body of the element as poetry, that is, obey line endings. [c raw#[poetry BODY]#]].

[def | verbatim | No formatting at all: obey line endings and white space. [c raw#[poetry BODY]#]].

[def | list | Construct a list of items using the form [c raw#[list [tem ...] [item ...] ...]#]  The default is a bulleted list.  To change the "item symbol", add the argument [c raw#|s : SYMBOL-NAME|#], e.g., write [c raw#[list | s: ‡ | ...]#] to produce the example below.  For a numbered list, use the special form [c raw#[list | s: numbered | ...]#]
]


[b Example]

To produce the list

[list  | s: ‡ |

  [item Conservation of momentum]

  [item  Conservation of energy]

]

write

[cb raw##
[list  | s: ‡ |

  [item Conservation of momentum]

  [item  Conservation of energy]

]  ##]

## Images

### jpg, png, etc

Insert an image using the format [c raw#[image URL]#], where
 [c URL] is a link to the image.  The image below was inserted using the source text
[c raw#[image https://pcd ... jpg] #]

[image https://pcdn.columbian.com/wp-content/uploads/2018/04/0427_LIF_kidspost-herons-1226x0-c-default.jpg]


To change the width of an image to 150 pixels, say [c raw#[image | width: 150 | URL]#]


[image | width: 150| https://pcdn.columbian.com/wp-content/uploads/2018/04/0427_LIF_kidspost-herons-1226x0-c-default.jpg]

To add a caption, say [c raw#[image | width: 150, caption Egrets | URL]#]


[image | width: 150, caption: Egrets | https://pcdn.columbian.com/wp-content/uploads/2018/04/0427_LIF_kidspost-herons-1226x0-c-default.jpg]

The arguments to the image element are a comma-separated list of key-value pairs, [c key:value].  You have seen how the width key is used with a numeric value.  You can also say [c width: fill] to make the image as wide as possible.  This is the default.  Another key is [c placement], which can take values [c left], [c right], and [c center].

Below is a variant of the Egret image with placement on the left.  We will have floating placement left and right in the near future.

[image | width: 150, caption: Egrets , placement: left| https://pcdn.columbian.com/wp-content/uploads/2018/04/0427_LIF_kidspost-herons-1226x0-c-default.jpg]


[b Note.] To copy the link of an image on the web, do control-click or right-click on the image and select "Copy image link" from the popup menu.

### SVG

Insert SVG images like the one you see below using the format below

[cb raw#[svg | caption: Circuit | <svg ... </svg>]#]

Here [c raw#<svg ... </svg>#] is the raw SVG source text.

[fontRGB |200, 0, 0| Still working on getting placement, etc. to work properly.]

[svg | caption: Circuit, placement: left |

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="49.894897mm"
   height="38mm"
   viewBox="0 0 49.894897 38"
   version="1.1"
   id="svg8"
   inkscape:version="0.92.3 (2405546, 2018-03-11)"
   sodipodi:docname="simple-electric-circuit.svg">

  <g
     inkscape:label="Ebene 1"
     inkscape:groupmode="layer"
     id="layer1"
     transform="translate(-37.177826,-18.387941)">
    <g
       id="g959"
       transform="translate(1.0394345,0.09980161)">
      <path
         inkscape:connector-curvature="0"
         id="path954"
         d="m 79.825353,39.645456 1.996096,-5.281152"
         style="fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <ellipse
         style="fill:none;stroke:#000000;stroke-width:0.50000006;stroke-linecap:round;stroke-miterlimit:4;stroke-dasharray:none"
         id="path941"
         cx="79.478828"
         cy="35.278759"
         rx="0.83578569"
         ry="0.83781064" />
      <ellipse
         ry="0.83781064"
         rx="0.83578569"
         cy="40.537014"
         cx="79.478828"
         id="ellipse943"
         style="fill:none;stroke:#000000;stroke-width:0.50000006;stroke-linecap:round;stroke-miterlimit:4;stroke-dasharray:none" />
    </g>
    <path
       id="path907"
       d="m 61.992992,45.381171 a 3.3158833,3.3158388 0 1 0 0.19505,0 z m 2.340624,0.975242 -4.681247,4.681184 m 0,-4.681184 4.681247,4.681184"
       inkscape:connector-curvature="0"
       style="fill:none;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none" />
    <path
       id="path920"
       style="stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none"
       d="m 55.560489,22.475897 h 1.984372 m 10.519197,4.762499 h -5.357811 m -2.38125,0 h -5.357811 m 5.357811,2.182807 v -4.365622 m 2.38125,-3.770309 V 33.19152 m 4.564064,-10.715623 h -1.984372 m 0.992182,-0.99219 v 1.984372"
       inkscape:connector-curvature="0" />
    <path
       style="fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="m 64.955204,27.238396 h 15.563519 v 7.231039"
       id="path923"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="m 80.518723,41.620149 v 7.076856 H 65.451474"
       id="path925"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="ccc" />
    <path
       style="fill:none;stroke:#000000;stroke-width:0.5;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 58.732947,48.697005 H 43.46726 V 27.238396 h 14.608779"
       id="path927"
       inkscape:connector-curvature="0"
       sodipodi:nodetypes="cccc" />
  </g>
</svg>

]


## Data

[def | sum |
  Compute sum of a list of numbers, e.g., [c raw#[sum 1, 2, 3]#] renders as [ds [sum 1, 2, 3]].]

[def | average |
  Compute average of a list of numbers, e.g., [c raw#[average 1, 2, 3]#] renders as [ds [average 1, 2, 3]].]

[def | stdev |
  Compute standard deviation of a list of numbers, e.g., [c raw#[stdev 1, 2, 3]#] renders as [ds [stdev 1, 2, 3]].]

## Macros

We have implemented a primitive version of macro expansion. To show how it works, begin by writing the macro definition

[cb raw#[macro [
    blue [ fontRGB |0, 80, 200| ]
]]#]

in the source text. Such a definition has the form

[cb raw#[macro [
  MACRO-NAME [ NAME |ARGS| ]
]]#]

where [c NAME] is the name of a standard element like [c fontRGB] and where
[c ARGS] is the actual list of arguments that the standard element will use.

When you add the macro definition, you will not see anything rendered. Now add this to the source "[c raw#[blue light blue bird's eggs]#]". You will see this:

[indent [blue light blue bird's eggs]]

### Composability


One can use macro instances pretty much as one uses elements.  Elements can be applied to macro instances, as with

[indent [i [blue light blue bird's eggs]]]

where the source text  is

[cb raw#[i [blue light blue bird's eggs]]#]

The body of a macro instance can also be an element:  [blue light [b blue] bird's eggs], where the source text is

[cb raw#[blue light [b blue] bird's eggs]#]

Finally, one can compose macro instances.  Make the definition

[cb raw#[macro [red [fontRGB |200, 0, 0| ]]]#]

and then say

[cb raw#[blue light blue with [red red spotted] bird's eggs]# ]

to obtain

[indent [blue light blue and [red red spotted] bird's eggs]]

[macro [blue [fontRGB |0, 80, 200| ]]]

[macro [red [fontRGB |200, 0, 0| ]]]


## What's left

data
linegraph
bargraph
macro
scatterplot







"""


foo =
    """
[section2 Graphs and Charts]

[def | bargraph |

Construct a bar graph from data in CSV format, e.g., the text

[cb raw#[bargraph
1
1.5
3
0.2
]#
]

renders as

[bargraph
1
1.5
3
0.2
]

]
]
"""


notes =
    """




[title Design Notes]

Following are some random notes on the structure of the cayatex compiler.  Our aim is to capture
the main ideas of the design while they are still in current memory.
All is subject to radical revision, as the project is still in a high-flux experimental state.

[tableofcontents]

# Syntax

The syntax of CaYaTeX is as in the example below:

[codeblock

raw###
Whiskey is [b very] strong stuff.###
]

It renders as "Whiskey is [b very] strong stuff."  All CaYaTeX source text consists of ordinary text, which may contain unicode characters, and [i basic elements], which are of one of three forms:

[list

[item [code raw##[NAME]##]]

[item [code raw##[NAME BODY]##]]

[item [code raw##[NAME |ARGS| BODY]##]]

]

where [code ARGS] is a comma-separated list of strings. Below is an example of the third form, where the data is in CSV format.

[codeblock

raw###
[bargraph | column:2, yShift: 0.2,
  caption: Sales of XYZ |
1, 2.1
2, 2.9
...
]###
]

[bargraph | column:2, yShift: 0.2,
  caption: Sales of XYZ |
1, 2.1
2, 2.9
3, 4.4
4, 6.8
5, 7.1
6, 7.8
7, 5.9
]

As an example of the first form, the table of contents is constructed via the element [code raw#[tableofcontents]#].
As to the structure of a general syntactic element, we have the following three formation rules:

[list |s: numbered|

[item Plain text is a syntactic element]

[item Basic elements are syntactic elements and the body of a syntactic element is a syntactic element]

[item A sequence [i a b c d ...] where each of [i a, b, c, d, ...] is a syntactic element is also a syntactic element]

]

# Parse Tree


Cayatex is built around the type of the parse tree.  This type captures the syntax of the source text as described above.

[codeblock
raw###
type Element
    = Text String (Maybe Metadata)
    | Element String (List String) Element (Maybe Metadata)
    | LX (List Element) (Maybe Metadata)###
]

The [c Metadata] component is carries data used in rendering the element or in interacting with an editor: section numbers, cross-refrences, location of the corresponding text in in the source, etc.

Note the distinction between syntactic element and Element.  The first is a decription of text formed by certain rules.  The second, while it reflects the first, is a type.

# Parser

Parsing, which is intended gracefully handle errors in the source text, such as unmatched brackets, is described below.  It is a three-stage process that produces a valid syntax tree despite the presence of error:  errors are both corrected and annotated.  Thus, when rendered, the text is readable and errors called out in-line in color so that the author can more easily understand and correct them.

The first step in parsing a document is to attempt to break the input text, given as a list of lines, into a list of special strings called [i blocks].  A block is string which is valid syntactic element.  Thus 

[cb raw#abc [x 1] def [y[z 2]] ghi#] 

is a block  as is the multi-line text

[cb raw#abc [x 1]
 def [y[z
 2]] ghi#] 

The previous text with the rightmost brace removed is not a block.  

Division of the text into blocks can fail, as it does with the last example of unbalanced brackets.  When this occurs, the parser invokes a backtracking strategy to  correct the text and then divide it into blocks.


[list | s: numbered |

[item Decompose the source text into blocks and feed these to [code Parser.Driver.parseLoop] using [code Parser.Lines.runLoop]].  Here is a synopsis of the parsing process:


[item Parse a list of elements from a block of input text using [code Parser.Driver.parseLoop].  The [c parseLoop] function does this by repeatedly running  [code Parser.Element.parser], truncating the input text each time.
]

[item Parse one element from the input text using [code Parser.Element.parser]]

]


## Parser.Element

Low-level parsing is handled by the function [code Parser.Element.parser]:

[codeblock
parser : Int -> Int -> Parser Element
]

The first two arguments are [code generation] and [code blockOffset].  These are "fed" to the parser by [code Parser.Driver.parseLoop].  The [c generation] argument is used for live editing-rendering and is incremented on each character stroke.  It is used downstream to manage updates to the virtual DOM.  The [c blockOffset] field is an index in the source text of the text parsed.

Note every variant of type [c Element] has a component of type [c Meta].
This metadata component is a record of the following type.

[cb type alias Metadata =
    { blockOffset : Int
    , offset : Int
    , length : Int
    , generation : Int
    , label : String
    }
]

The first three fields are used to locate the text parsed in the source text.  The last, [c label], is computed when the text is parsed.  For example, if the element is  [c raw#[section3 Foo]#], the label might be the string [c 5.2.1].  Labels are used to render the output of the parser.

## Parser.Driver

The next level up in parsing text is handled by [c parseLoop], whose type is given below. [i Grosso modo], it functions by applying [c Element.parser] to the input string, analyzing the result, doing some computations, and  dropping the substring just parsed from the input text, and adding the parsed result to a field of [c TextCursor].


[cb
parseLoop : Int -> Int -> Data -> String -> TextCursor Element
parseLoop generation initialLineNumber data str = ...
]

Let's look at this in more detail.  The [c TextCursor] type, which we use as [c TextCursor Element], is as laid out below. Many of the fields have already been discussed already

[cb
type alias TextCursor a =
    { text : String           -- text remaining to be processed
    , block : String
    , parsand : Maybe a       -- element just parsed
    , parsed : List a         -- elements parsed so far
    , stack : List String
    , blockIndex : Int
    , offset : Int
    , count : Int
    , generation : Int
    , data : Parser.Data.Data  -- data accumulated so far
    }

]

The [c data] field is of particular interest.  Its type is as listed below.  In it, the parser accumulates information about the source text that is used in rendering.  The [c vectorCounters] field, for example is used to set the label of a section element.

[cb
type alias Data =
    { counters : IntegerDict
    , vectorCounters : VectorDict
    , crossReferences : Dictionary
    , tableOfContents : List TocEntry
    , dictionary : Dictionary
    , config : Config
    }
]

## Error recovery

The [c parseLoop] function handles error recovery by modifiying the parse tree so as
to (a) correct the error (b) highlight it in the rendered text.  A comment on the nature of the error
is inserted in the TextCursor.  This comment is used by the supervising Parser.Lines runLoop
function which backtracks as needed to properly reparse the remaining text.

## Parser.Lines

The highest level of the parser is handled by [c Parser.Lines.runLoop]:

[cb
runLoop : Int -> List String -> State
runLoop generation strList = ...
]

This function takes as input data supplied by the editor: the generation number and the source text presented as a list of strings.  Its output is a value of type [c State], as described below.  The [c input] field is the source text, which is progresselvely truncated as [c runLoop] proceeds, building up (
i) a [c Data] value, (ii) a list of [c TextCursor].  The [c parsed] field of a text cursor holds the parsed text.

The task of the function [c runLoop] is to divide the input text into logical elements (strings), which are then fed to [c Driver.parseLoop].  The return value of [c Driver.parseLoop] is used to compute the new [c State].  A logical element is either (i) a paragraph, defined as an element sequence beginning with plain text and bounded above and below
by blank lines or (ii) an element of the form [c NAME ... ] bounded above and below by blanke lines.


[cb

type alias State =
    { input : List String
    , blockOffset : Int
    , generation : Int
    , blockType : BlockStatus
    , blockContents : List String
    , blockLevel : Int
    , output : List (TextCursor Element)
    , data : Parser.Data.Data
    }

]


If [c state] is the final value computed by [c runLoop], then the code

[cb raw#
state
   |> .output
   |> List.map .parsed
   |> List.reverse
 #  ]

produces a value of type [c List (List Element)] which can then be fed to the rendering machine.  The renderer also requires the [c state.data] field.


                  
"""


test =
    """
[tableofcontents]

[section1 A]

 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

[section2 B]

 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

[section3 C]

 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

[section4 D]


 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

[section5 E]


 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.

[section6 F]


 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in sem eget mi cursus posuere sagittis a neque. Mauris ut fringilla velit. Aenean sit amet odio nec quam pretium sodales eget sed nibh. Etiam vel dui non nibh finibus vehicula eget eu purus. Sed fermentum dignissim mi gravida pretium. Aenean auctor interdum vulputate. Donec aliquet velit nibh, a ultricies mi posuere ut. Praesent id hendrerit odio. Nam eu elit a ipsum eleifend faucibus a id mauris. Vestibulum nec feugiat urna. Fusce congue odio non erat molestie, ut pharetra mi dapibus.

Donec ultrices magna iaculis augue porta dignissim. Aenean dui felis, molestie ut dapibus quis, tristique a lacus. Sed vulputate, ligula id consequat venenatis, enim odio sagittis nisl, vel tincidunt ligula velit quis erat. Pellentesque ultricies luctus risus, sit amet aliquam justo congue id. Aliquam consectetur arcu nec risus malesuada pellentesque. Nam tincidunt, nisl sed congue ullamcorper, ante nibh tempus elit, et fringilla magna diam elementum enim. Pellentesque quam nisl, tempus non metus vestibulum, varius tempus mauris. Maecenas fermentum tristique enim vitae pulvinar. Aenean id metus non nisi sagittis consequat. Integer nec erat luctus urna semper lobortis vel non neque. In semper scelerisque enim in lacinia. Praesent ut interdum felis. Quisque vitae ornare velit.


"""


announcement =
    """



[title Announcing CaYaTeX]

By James Carlson and Nicholas Yang



[italic CaYaTeX, an experiment-in-progress, is a simple yet powerful markup language that
compiles to both LaTeX and Html. The implementation you see
here is written in Elm: [link |github.com/jxxcarlson/cayatex| https://github.com/jxxcarlson/cayatex]].

[i Credits and thanks to Matt Griffith and Rob Simmons whose error recovery work inspired what is done here.]

[i  Please do edit/delete/replace any of the text here. It won't be saved.]

[i  [c Of special importance: make syntax errors (missing brackets, extra brackets, etc.)
We are working to handle all errors gracefully and would like to know about the bugs, cases missed, etc.  Comments to jxxcarlson@gmail.com]]

[tableofcontents]

[i [fontRGB |60, 60, 60| Click on an item in the table of contents to go to the corresponding section.  Click on a section title
to return to the table of contents.]]

# Design Goals

The goals of the CaYaTeX project are for the language to be

[list |numbered|

[item [bold Small], hence easy to learn. [i To this end there are just two constructs: ordinary text and [code elements]].]

[item [b Powerful].  We borrow ideas from functional programming.
Elements have a Lisp-like syntax with brackets in place of parentheses.
An element has the basic form [code raw##[name |argument-list| body]##].
The parts [code raw##|argument-list|##] and [c body] may or may not be present.
The argument list is a comma-delimited sequence of
strings.  The body is an element.
The partial element [code name args] is a function [code Element -> Element].
Such functions can be composed, as in mathematics or as in languages such as Haskell and Elm.
]


[item [b Extensible] via macro definitions made in the source text.]

[item [b Multiple inputs and outputs.] Documents written in CaYaTeX can be compiled to LaTeX, Markdown, and HTML. Markdown documents can be compiled to CaYaTeX.]

[item [b Web-ready]. CaYaTeX has a differential compiler that makes it suitable for real-time editing, e.g.,  in a web app. ]

[item [b Kind and Helpful]. Displays friendly and informative error messages in real time in the rendered text; has hooks for highlighting the corresponding source text in a suitable IDE/editor.]

[item [b Modern]. Unicode compatible.]]


Certain tasks are particularly simple with cayatex: insertion of images referenced by URL, construction of tables, graphs, and plots from data given in a standard format such as CSV, and also inline compatations of statistical data. Examples of these are given below.

Our goal is to have a convenient  tool for writing technical documents that are immediately publishasble on the web while at the same time offering export to conventional formats such as LaTeX (and therefore also) PDF.


[b Note.] [fontRGB |50, 0, 200| The above are desiderata.  Among the missing items: compile to LaTeX and differential compilation, which is needed for snappy, real-time rendering of the source text while editing. Our first objectives
are a decent proof-of-concept and error-handling that is both robust and graceful. All in due time!]


# Showcase


## Mathematics


Pythagoras says that [math a^2 + b^2 = c^2].
This is an [b [i extremely]] cool result. But just as cool is the below:

[mathblock \\sum_{n=1}^\\infty \\frac{1}{n} = \\infty,]

which goes back to the work of Nicole Oresme (1320–1382).  See the entry in the
[link |Stanford Encyclopedia of Philosophy| https://plato.stanford.edu/entries/nicole-oresme/].
You can also consult [link https://en.wikipedia.org/wiki/Nicole_Oresme].

We can also do some high-school math, with that beautifully curved integral sign
that attracts so many people to the subject:

[mathblock \\int_0^1 x^n dx = \\frac{1}{n+1}]

And of course, we can also do theorems:

[theorem There are infinitely many primes [math p \\equiv 1 	ext{ mod } 4.]]

[corollary |Euclid| There are infinitely many primes.]



## Macros

We have implemented a primitive version of macro expansion. To show how it works, begin by writing the macro definition

[cb raw#[macro [
    blue [ fontRGB |0, 80, 200| ]
]]#]

in the source text. Such a definition has the form

[cb raw#[macro [
  MACRO-NAME [ NAME |ARGS| ]
]]#]

where [c NAME] is the name of a standard element like [c fontRGB] and where
[c ARGS] is the actual list of arguments that the standard element will use.

When you add the macro definition, you will not see anything rendered. Now add this to the source "[c raw#[blue light blue bird's eggs]#]". You will see this:

[indent [blue light blue bird's eggs]]

### Composability


One can use macro instances pretty much as one uses elements.  Elements can be applied to macro instances, as with

[indent [i [blue light blue bird's eggs]]]

where the source text  is

[cb raw#[i [blue light blue bird's eggs]]#]

The body of a macro instance can also be an element:  [blue light [b blue] bird's eggs], where the source text is

[cb raw#[blue light [b blue] bird's eggs]#]

Finally, one can compose macro instances.  Make the definition

[cb raw#[macro [red [fontRGB |200, 0, 0| ]]]#]

and then say

[cb raw#[blue light blue with [red red spotted] bird's eggs]# ]

to obtain

[indent [blue light blue and [red red spotted] bird's eggs]]

[macro [blue [fontRGB |0, 80, 200| ]]]

[macro [red [fontRGB |200, 0, 0| ]]]




##  Color

Example:  [highlightRGB |252, 178, 50| [fontRGB |23, 57, 156| [b What color is this?]]]

[code raw###[highlightRGB |252, 178, 50| [fontRGB |23, 57, 156| [b What color is this?]]]###]


Note the nesting of elements, aka function composition. When we have our macro facility up and running,  users can abbreviate constructs like
this one, e.g., just say [code raw##[myhighlight| What color is this?]##]


## Variables

One can set variables to be used elsewhere in the text.  For example, if we
say [c raw#[set [project = Gaia Unlimited, pi = 3.1416]#], we can later say
"my project is [c raw#[get project]#]," which will be rendered as "my project is [get project]."

The variable pi is also defined: pi = [get pi].  Here we said [c raw#pi = [get pi]#].

The [c set ...] statements can be placed anywhere in the document, for example, at the end.
Note that [c set ...] statements are not rendered in the text.  If you do want it to be rendered,
use [c set_ ...] instead.

[set project = Gaia Unlimited, pi = 3.1416]

## Spreadsheets

The below demonstrates the use
of a rudimentary spreadsheet element.  We plan a pop-up editor for
these spreadsheets.

### Rendered spreadsheet

[spreadsheet

[row 100.0, 1.1, row * 1 2 ]

[row 120.0, 1.4 ,row * 1 2 ]

[row 140.0, 0.9 ,row * 1 2]

[row -, col sum 1 3, col sum 1 3]

]



### Source text

[cb raw##
[spreadsheet

[row 100.0, 1.1, row * 1 2]

[row 120.0, 1.4 ,row * 1 2]

[row 140.0, 0.9 ,row * 1 2]

[row -, col sum 1 3, col sum 1 3]

]##]

The entry [c row * 1 2] in the upper right-hand  cell means "In this row, multiply
the cells in columns 1 and 2; use that value to replace me."  Similarly, the entry
[c col sum 1 3] menas, "in the column where I am, compute sum of  the cell contents in rows 1 through 3; use that value to replace me.

## Data

One can design elements which manipulate data (numerical computations, visualization).  Here are some data computations:

[sum 1.2, 2, 3.4, 4]

[average 1.2, 2, 3.4, 4]

[stdev |precision:3| 1.2, 2, 3.4, 4]

In the numerical examples, the precision of the result has a default value of 2.  This can be changed, as one sees in the source of the third example, e.g., you can have

[codeblock raw##[stdev | 1.2, 2, 3.4, 4]## ]

or

[codeblock raw##[stdev |precision:3| 1.2, 2, 3.4, 4]## ]


## Graphs

Below are three simple data visualizations. We plan more, and more configurability of what you see here.

### Bar graphs

[bargraph |column:2, yShift: 0.2, caption: Global temperature anomaly 1880-1957|
1880,-0.12
1881,-0.07
1882,-0.07
1883,-0.15
1884,-0.21
1885,-0.22
1886,-0.21
1887,-0.25
1888,-0.15
1889,-0.10
1890,-0.33
1891,-0.25
1892,-0.30
1893,-0.31
1894,-0.28
1895,-0.22
1896,-0.09
1897,-0.12
1898,-0.26
1899,-0.12
1900,-0.07
1901,-0.14
1902,-0.25
1903,-0.34
1904,-0.42
1905,-0.29
1906,-0.22
1907,-0.37
1908,-0.44
1909,-0.43
1910,-0.38
1911,-0.43
1912,-0.33
1913,-0.31
1914,-0.14
1915,-0.07
1916,-0.29
1917,-0.31
1918,-0.20
1919,-0.20
1920,-0.21
1921,-0.14
1922,-0.22
1923,-0.21
1924,-0.24
1925,-0.14
1926,-0.06
1927,-0.14
1928,-0.17
1929,-0.29
1930,-0.09
1931,-0.07
1932,-0.11
1933,-0.24
1934,-0.10
1935,-0.14
1936,-0.11
1937,-0.01
1938,-0.02
1939,-0.01
1940,0.10
1941,0.19
1942,0.15
1943,0.16
1944,0.29
1945,0.17
1946,-0.01
1947,-0.05
1948,-0.06
1949,-0.06
1950,-0.17
1951,-0.01
1952,0.02
1953,0.09
1954,-0.12
1955,-0.14
1956,-0.20
1957,0.05
]

The bargraph code:

[codeblock raw##[bargraph |column:2,
    caption: Global temperature anomaly 1880-1957|
1880,-0.12
1881,-0.07
...]## ]

### Line graphs

[linegraph |caption: Global temperature anomaly 1880-1957|
1880,-0.12
1881,-0.07
1882,-0.07
1883,-0.15
1884,-0.21
1885,-0.22
1886,-0.21
1887,-0.25
1888,-0.15
1889,-0.10
1890,-0.33
1891,-0.25
1892,-0.30
1893,-0.31
1894,-0.28
1895,-0.22
1896,-0.09
1897,-0.12
1898,-0.26
1899,-0.12
1900,-0.07
1901,-0.14
1902,-0.25
1903,-0.34
1904,-0.42
1905,-0.29
1906,-0.22
1907,-0.37
1908,-0.44
1909,-0.43
1910,-0.38
1911,-0.43
1912,-0.33
1913,-0.31
1914,-0.14
1915,-0.07
1916,-0.29
1917,-0.31
1918,-0.20
1919,-0.20
1920,-0.21
1921,-0.14
1922,-0.22
1923,-0.21
1924,-0.24
1925,-0.14
1926,-0.06
1927,-0.14
1928,-0.17
1929,-0.29
1930,-0.09
1931,-0.07
1932,-0.11
1933,-0.24
1934,-0.10
1935,-0.14
1936,-0.11
1937,-0.01
1938,-0.02
1939,-0.01
1940,0.10
1941,0.19
1942,0.15
1943,0.16
1944,0.29
1945,0.17
1946,-0.01
1947,-0.05
1948,-0.06
1949,-0.06
1950,-0.17
1951,-0.01
1952,0.02
1953,0.09
1954,-0.12
1955,-0.14
1956,-0.20
1957,0.05
]

The linegraph code (CSV format):

[codeblock raw##[linegraph |caption: Global
temperature anomaly 1880-1957|
1880,-0.12
1881,-0.0]##]

### Scatter plots

Use the same syntax as before, but with "scatterplot" in place of "linegraph."

[code raw##[scatterplot |x-axis:3,  y-axis:4
  , caption: Hubble's 1929 data| ...]##]

[scatterplot |x-axis:3,  y-axis:4, caption: Hubble's 1929 data|
object,ms,R (Mpc),v (km/sec),mt,Mt,"D from mt,Mt",,,,,,,,,
S.Mag.,..,0.032,170,1.5,-16.0,0.03,Slope when Intercept set to zero,423.901701290206,km/sec/Mpc,,,,,,
L.Mag.,..,0.03,290,0.5,-17.2,0.03,,,,,,,,,
N.G.C.6822,..,0.214,-130,9,-12.7,0.22,Slope,453.85999408475,km/sec/Mpc,,,,,,
598,..,0.263,-70,7,-15.1,0.26,Intercept,-40.4360087766413,km/sec,,,,,,
221,..,0.275,-185,8.8,-13.4,0.28,R Squared,0.623168376295362,,,,,,,
224,..,0.275,-220,5,-17.2,0.28,,,,,,,,,
5457,17,0.45,200,9.9,-13.3,0.44,,,,,,,,,
4736,17.3,0.5,290,8.4,-15.1,0.50,,,,,,,,,
5194,17.3,0.5,270,7.4,-16.1,0.50,,,,,,,,,
4449,17.8,0.63,200,9.5,-14.5,0.63,,,,,,,,,
4214,18.3,0.8,300,11.3,-13.2,0.79,,,,,,,,,
3031,18.5,0.9,-30,8.3,-16.4,0.87,,,,,,,,,
3627,18.5,0.9,650,9.1,-15.7,0.91,,,,,,,,,
4826,18.5,0.9,150,9,-15.7,0.87,,,,,,,,,
5236,18.5,0.9,500,10.4,-14.4,0.91,,,,,,,,,
1068,18.7,1,920,9.1,-15.9,1.00,,,,,,,,,
5055,19,1.1,450,9.6,-15.6,1.10,,,,,,,,,
7331,19,1.1,500,10.4,-14.8,1.10,,,,,,,,,
4258,19.5,1.4,500,8.7,-17.0,1.38,,,,,,,,,
4151,20,1.7,960,12,-14.2,1.74,,,,,,,,,
4382,..,2,500,10,-16.5,2.00,,,,,,,,,
4472,..,2,850,8.8,-17.7,2.00,,,,,,,,,
4486,..,2,800,9.7,-16.8,2.00,,,,,,,,,
4649,..,2,1090,9.5,-17.0,2.00,,,,,,,,,
Table 1,,,,,-15.5,,,,,,,,,,
]

## Tables

[data |title:Atomic weights, header|

N,  Symbol,  Name, W
1, H, Hydrogen,1.008
2, He, Helium, 4.002
3, Li, Lithium, 6.94
4, Be, Beryllium, 9.012
5, B, Boron, 10.81
6, C, Carbon, 12.011
7, N, Nitrogen, 14.007
8, O, Oxygen, 15.999
9, F, Fluorine, 18.998
10, Ne, Neon, 20.1797
11, Na, Sodium, 22.989
12, Mg, Magnesium, 24.305
13, Al, Aluminium, 26.981
14, Si, Silicon, 28.085
15, P, Phosphorus, 30.973
16, S, Sulfur, 32.06
17, Cl, Chlorine, 35.45
18, Ar, Argon, 39.948
19, K, Potassium, 39.0983
20, Ca, Calcium, 40.078

]


## Table of contents

A table contents is generated automatically if you place
the element [c raw#[tableofcontents]#] in the source text.
Entries in the table of contents are active links to the
indicated sections.  Conversely, section titles act
as active links back to the table of contents.

Sections up to six levels deep are available.


33 Unicode

You can freely use unicode characters, as in this poetry element:

[poetry
А я иду, где ничего не надо,
Где самый милый спутник — только тень,
И веет ветер из глухого сада,
А под ногой могильная ступень.

— Анна Ахматова
]

## Shortcuts

[verbatim

raw###
Note that instead of saying [italic ...  ],
you can say [i .... ]

There are shortcuts for a few
other common elements:
[b ...] instead of [bold ... ]
[m ...] instead of [math ... ]
[mb ...] instead of [mathblock ... ]###

]

## Code

Time for some code: [code raw##col :: Int -> Matrix a -> [a]##].
Do you recognize the language (ha ha)?

We can also do code blocks.  Syntax highlighting coming later.

[codeblock raw##
For Sudoku 3x3 subsquare function
1298col k = fmap ( !! k)

cols :: Matrix a -> Matrix a
cols m =
    fmap (\\k -> col k m) [0..n]
       where n = length m - 1  ##]



[i [highlight Note the use of Rust-like raw strings in the source text to avoid escaping all the brackets.]]




## Images

[image |caption: Rotkehlchen aufgeplustert, width: 200, placement: center|https://i.pinimg.com/originals/d4/07/a4/d407a45bcf3ade18468ac7ba633244b9.jpg]

[code raw##[image |caption: Rotkehlchen aufgeplustert, width: 200, placement: center| https://..jpg]##]
1296

[section2 SVG]

[svg
<svg xmlns="http://www.w3.org/2000/svg"
 width="467" height="462">
  <rect x="80" y="60" width="250" height="250" rx="20"
      style="fill:#ff0000; stroke:#000000;stroke-width:2px;" />

  <rect x="140" y="120" width="250" height="250" rx="40"
      style="fill:#0000ff; stroke:#000000; stroke-width:2px;
      fill-opacity:0.7;" />
</svg>
]

[c raw##[svg <svg ... SVG CODE ... </svg> ]##]

[section2 Lists]

Note that lists can be nested and can be given a title if desired.  The symbol for "bulleted" lists is • by default, but can be specified by the user.
A numbered list has "numbered" as its first argument, as in the example below.

[list |numbered, title:Errands and other stuff|

    [item Bread, milk, O-juice]

    [item Sand paper, white paint]

    [list |none|

        [item A]

        [item B]

        [list |§, title:Greek symbols|

            [item [math \\alpha = 0.123]]

            [item  [math \\beta = 4.567]]

]]]

[section1 Road map]

[list | s: numbered |

[item Improve error handling.]

[item As with section numbering, implement theorem numbering, cross-references, etc.]

[item Implement export to LaTeX]

[item Integrate bracket-matching editor.]


[item Add CaYaTeX as a markup language option
for [link https://minilatex.lamdera.app]. Presently MiniLaTeX,
Math+Markdown, and plain text are supported.
]


]

[section1 Appendix: Technical Stuff]

Because CaYaTeX is so simple, the type of the AST is very small:

[codeblock
  raw##type Element
    =   Text String Meta
      | Element String (List String) Element Meta
      | LX (List Element) Meta
  ##
 ]

The first variant, [code Text String] accounts for plain text.
The second is of the form [code Element name args body],
while the third shows how a list of elements combine to form an
element.  In particular, the body of an element can be
[code LX] of a list of elements.  The [code Meta] component tracks
location of the corresponding piece of text in the source code as well as
other metadata such as section numbering.

For more technical details, see the [c Design Notes] tab.



"""
