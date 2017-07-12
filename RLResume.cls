%-------------------------------------------------------------------------------
% RLResume based on ModernCV, Heavily gutted and customized
%-------------------------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{RLResume}[2017/07/12 v1.0.0 Riley Labrecque's Resume Class]

%-------------------------------------------------------------------------------
% Class options
%
% (need to be done before the external package loading, for example because
% we need \paperwidth, \paperheight and \@ptsize to be defined before loading
% geometry and fancyhdr)
%-------------------------------------------------------------------------------
\AtBeginDocument{\renewcommand{\familydefault}{\sfdefault}}

\setlength\overfullrule{0pt}
\setlength\paperheight{297mm}
\setlength\paperwidth{210mm}

\newcommand\@ptsize{1}
\input{size1\@ptsize.clo}

%-------------------------------------------------------------------------------
% Required packages
%-------------------------------------------------------------------------------
\RequirePackage{etoolbox} % \AtEndPreamble hook
\RequirePackage{ifthen} % if... then... else... constructs
\RequirePackage[table]{xcolor} % Color
\RequirePackage{calc} % Lengths calculations
\RequirePackage{xparse} % Advanced command arguments (LaTeX 3)
\RequirePackage{microtype} % Micro-typography (e.g., character protrusion, font expansion, hyphenatable letterspacing)
\RequirePackage{fontawesome} % Icons

% font loading
\RequirePackage{ifxetex,ifluatex}
\newif\ifxetexorluatex
\ifxetex
  \xetexorluatextrue
\else
  \ifluatex
    \xetexorluatextrue
  \else
    \xetexorluatexfalse
  \fi
\fi

\RequirePackage[T1]{fontenc}
\IfFileExists{lmodern.sty}%
  {\RequirePackage{lmodern}}%
  {}

% hyper links (hyperref is loaded at the end of the preamble to pass options required by loaded packages such as CJK)
\newcommand*\pdfpagemode{UseNone}% do not show thumbnails or bookmarks on opening (on supporting browsers); set \pdfpagemode to "UseOutlines" to show bookmarks
\RequirePackage{url}
\urlstyle{tt}
\AtEndPreamble{
  \pagenumbering{arabic}% has to be issued before loading hyperref, as to set \thepage and hence to avoid hyperref issuing a warning and setting pdfpagelabels=false
  \RequirePackage[unicode]{hyperref}% unicode is required for unicode pdf metadata
  \hypersetup{
    breaklinks,
    baseurl       = http://,
    pdfborder     = 0 0 0,
    pdfpagemode   = \pdfpagemode,
    pdfstartpage  = 1,
    pdfcreator    = {\LaTeX{} with 'moderncv' package},
%    pdfproducer   = {\LaTeX{}},% will/should be set automatically to the correct TeX engine used
    bookmarksopen = true,
    bookmarksdepth= 2,% to show sections and subsections
    pdfauthor     = {\@name{}},
    pdftitle      = {\@name{}\notblank{\@title}{ -- \@title}{}},
    pdfsubject    = {Resum\'{e} of \@name{}},
    pdfkeywords   = {\@name{}, curriculum vit\ae{}, resum\'{e}}}}

% reduced list spacing
% package providing hooks into lists
%   originally developped by Jakob Schiøtz (see http://dcwww.camd.dtu.dk/~schiotz/comp/LatexTips/tweaklist.sty)
%   modified and distributed with moderncv(not available otherwise on ctan)
\RequirePackage{tweaklist}
\renewcommand*{\itemhook}{%
  \@minipagetrue% removes spacing before lists as they use \addvspace, which doesn't add vertical space inside minipages
  \@noparlisttrue% removes spacing at end of lists, caused by \par
  \setlength{\topsep}{0pt}% normally not required thanks to \@minipagetrue
  \setlength{\partopsep}{0pt}% normally not required thanks to \@minipagetrue
  \setlength{\parsep}{0pt}% not required when \itemsep and \parskip are set to 0pt (?)
  \setlength{\parskip}{0pt}%
  \setlength{\itemsep}{0pt}}
\renewcommand*{\enumhook}{\itemhook{}}
\renewcommand*{\deschook}{\itemhook{}}


% creates a new collection
% usage: \collectionnew{<collection name>}
\newcommand*{\collectionnew}[1]{%
  \newcounter{collection@#1@count}}

% adds an item to a collection
% usage: \collectionadd[<optional key>]{<collection name>}{<item to add>}
\newcommand*{\collectionadd}[3][]{%
  \expandafter\def\csname collection@#2@item\roman{collection@#2@count}\endcsname{#3}%
  \if\relax\noexpand#1\relax% if #1 is empty
    \else\expandafter\def\csname collection@#2@key\roman{collection@#2@count}\endcsname{#1}\fi%
  \stepcounter{collection@#2@count}}

% returns the number of items in a collection
% usage: \collectioncount{<collection name>}
\newcommand*{\collectioncount}[1]{%
  \value{collection@#1@count}}

% gets an item from a collection
% usage: \collectiongetitem{<collection name>}{<element id>}
% where <element id> is an integer between 0 and (collectioncount-1)
\newcommand*{\collectiongetitem}[2]{%
  \csname collection@#1@item\romannumeral #2\endcsname}

% gets a key from a collection
% usage: \collectiongetkey{<collection name>}{<element id>}
% where <element id> is an integer between 0 and (collectioncount-1)
\newcommand*{\collectiongetkey}[2]{%
  \csname collection@#1@key\romannumeral #2\endcsname}

% loops through a collection and perform the given operation on every element
% usage: \collectionloop{<collection name>}{<operation sequence>}
% where <operation sequence> is the code sequence to be evaluated for each collection item,
%   code which can refer to \collectionloopid, \collectionloopkey, \collectionloopitem and
%   \collectionloopbreak
\newcounter{collection@iterator}
\newcommand*{\collectionloopbreak}{\let\iterate\relax}
\newcommand*{\collectionloop}[2]{%
  \setcounter{collection@iterator}{0}%
  \loop\ifnum\value{collection@iterator}<\value{collection@#1@count}%
    \def\collectionloopid{\arabic{collection@iterator}}%
    \def\collectionloopitem{\collectiongetitem{#1}{\collectionloopid}}%
    \def\collectionloopkey{\collectiongetkey{#1}{\collectionloopid}}%
    #2%
    \stepcounter{collection@iterator}%
    \repeat}

% loops through a collection and finds the (first) element matching the given key
% usage: \collectionfindbykey{<collection name>}{key>}
\newcommand*{\collectionfindbykey}[2]{%
  \collectionloop{#1}{%
    \ifthenelse{\equal{\collectionloopkey}{#2}}{\collectionloopitem\collectionloopbreak}{}}}

%-------------------------------------------------------------------------------
%                class definition
%-------------------------------------------------------------------------------
% minimal base settings
\setlength\lineskip{1\p@}
\setlength\normallineskip{1\p@}
\renewcommand\baselinestretch{}
\setlength{\parindent}{0\p@}
\setlength{\parskip}{0\p@}
\setlength\columnsep{10\p@}
\setlength\columnseprule{0\p@}
\setlength\fboxsep{3\p@}
\setlength\fboxrule{.4\p@}
\setlength\arrayrulewidth{.4\p@}
\setlength\doublerulesep{2\p@}

%-------------------------------------------------------------------------------
%                overall design commands definitions
%-------------------------------------------------------------------------------
% elements
%---------
% defines one's name
% usage: \name{<name>}
\newcommand*{\name}[1]{\def\@name{#1}}

% adds a phonme number to one's personal information (optional)
% usage: \phone{<number>}
\newcommand*{\phone}[1]{\def\@phone{#1}}

% defines one's email (optional)
% usage: \email{<email adress>}
\newcommand*{\email}[1]{\def\@email{#1}}

% defines one's home page (optional)
% usage: \homepage{<url>}
\newcommand*{\homepage}[1]{\def\@homepage{#1}}

% adds a social link to one's personal information (optional)
% usage: \social[<optional type>][<optional url>]{<account name>}
% where <optional type> should be either "linkedin", "twitter" or "github"
\collectionnew{socials}
\NewDocumentCommand{\social}{O{}O{}m}{%
  \ifthenelse{\equal{#2}{}}%
    {%
      \ifthenelse{\equal{#1}{linkedin}}{\collectionadd[linkedin]{socials}{\protect\httplink[#3]{www.linkedin.com/in/#3}}}{}%
      \ifthenelse{\equal{#1}{twitter}} {\collectionadd[twitter]{socials} {\protect\httplink[#3]{www.twitter.com/#3}}}    {}%
      \ifthenelse{\equal{#1}{github}}  {\collectionadd[github]{socials}  {\protect\httplink[#3]{www.github.com/#3}}}     {}%
    }
    {\collectionadd[#1]{socials}{\protect\httplink[#3]{#2}}}
}

% colors
%-------
\definecolor{color0}{rgb}{0,0,0}% black
\definecolor{color1}{rgb}{0.22,0.45,0.70}% light blue
\definecolor{color2}{rgb}{0.45,0.45,0.45}% dark grey
\definecolor{color3}{rgb}{0,0,0}% tertiary scheme color

% symbols
%--------
% itemize labels (the struts were added to correct inter-item spacing (works for single line items, until a solution is found for multi-line ones...)
\newcommand*{\labelitemi}          {\strut\textcolor{color1}{\tiny\faCircleO}}% the \rmfamily is required to force Latin Modern fonts when using sans serif, as OMS/lmss/m/n is not defined and gets substituted by OMS/cmsy/m/n
\newcommand*{\labelitemii}         {\strut\textcolor{color1}{\large\bfseries-}}
\newcommand*{\labelitemiii}        {\strut\textcolor{color1}{\rmfamily\textperiodcentered}}% alternative: \textasteriskcentered; the \rmfamily is required to force Latin Modern fonts when using sans serif, as OMS/lmss/m/n is not defined and gets substituted by OMS/cmsy/m/n
\newcommand*{\labelitemiv}         {\labelitemiii}

\newcommand*{\listitemsymbol}      {\labelitemi~}

\newcommand*{\mobilephonesymbol}   {{\Large\faMobile}~}
\newcommand*{\emailsymbol}         {{\small\faEnvelopeO}~}
\newcommand*{\homepagesymbol}      {{\small\faGlobe}~}
\newcommand*{\linkedinsocialsymbol}{{\small\faLinkedin}~}
\newcommand*{\twittersocialsymbol} {{\small\faTwitter}~}
\newcommand*{\githubsocialsymbol}  {{\small\faGithub}~}

% fonts
\newcommand*{\namefont}{}
\newcommand*{\sectionfont}{}
\newcommand*{\subsectionfont}{}

% styles
\newcommand*{\namestyle}[1]{{\namefont#1}}
\newcommand*{\sectionstyle}[1]{{\sectionfont#1}}
\newcommand*{\subsectionstyle}[1]{{\subsectionfont#1}}


% other
%------
% fonts
\AtBeginDocument{\normalfont\color{color0}}

% loads a header variant
% usage: \moderncvhead[<optional head option>]{<header variant number>}
\newcommand*{\moderncvhead}{
  \RequirePackage{Header}
}%

% loads a body variant
% usage: \moderncvbody[<optional body option>]{<body variant number>}
\newcommand*{\moderncvbody}{
  \RequirePackage{Body}
}

\AtBeginDocument{\recomputecvbodylengths{}}

% creates a command if not yet defined
\newcommand*{\@initializecommand}[2]{%
  \ifdefined#1
    \renewcommand{#1}{#2}%
  \else%
    \newcommand*{#1}{#2}\fi}

% creates a length if not yet defined
\newcommand*{\@initializelength}[1]{%
  \ifdefined#1
  \else%
    \newlength{#1}\fi%
  \setlength{#1}{0pt}}

% creates a box if not yet defined
\newcommand*{\@initializebox}[1]{%
  \ifdefined#1
    \savebox{#1}{}%
  \else%
    \newsavebox{#1}\fi}

% creates an if switch if not yet defined
\newcommand*{\@initializeif}[1]{%
%  \ifdefined#1% not working due to the nested \if
%  \else%
    \newif#1%\fi
  }

% custom strut for spacing; the first argument is the vertical offset of the strut, the second its total height
\newcommand*{\@moderncvstrut}[2]{%
  \rule[-#1]{0pt}{#2}}

% internal maketitle command to issue a new line only when required
\newif\if@firstdetailselement\@firstdetailselementtrue
\newcommand*{\makenewline}[1][0pt]{%
  \if@firstdetailselement%
    \strut% to ensure baseline alignment, e.g. with when put in the margin vs sections that also contains a \strut
  \else%
    \\[#1]\fi%
  \@firstdetailselementfalse}

\title{}% to avoid LaTeX complaining that \maketitle is a called without first a call to \title
\newcommand*{\makecvtitle}{%
  \makecvhead%
  \makecvfoot}
\newcommand*{\makecvhead}{}
\newcommand*{\makecvfoot}{}

% makes a resume section
% usage: \section{<title>}
% identical starred and non-starred variants should be defined for compatibility with other packages (e.g. with natbib, that uses \section*{} for the bibliography header)
\NewDocumentCommand{\section}{sm}{}

% makes a resume subsection
% usage: \subsection{title}
\NewDocumentCommand{\subsection}{sm}{}

% makes a resume line with a header and a corresponding text
% usage: \cvitem[spacing]{header}{text}
\newcommand*{\cvitem}[3][.25em]{}

% makes a resume line 2 headers and their corresponding text
% usage: \cvdoubleitem[spacing]{header1}{text1}{header2}{text2}
\newcommand*{\cvdoubleitem}[5][.25em]{}

% makes a resume line with a list item
% usage: \cvlistitem[label]{item}
\newcommand*{\cvlistitem}[2][\listitemsymbol]{}

% makes a resume line with 2 list items
% usage: \cvlistdoubleitem[label]{item1}{item2}
\newcommand*{\cvlistdoubleitem}[3][\listitemsymbol]{}

% makes a typical resume job / education entry
% usage: \cventry[spacing]{Years}{Job title}{Employer}{localization}
\newcommand*{\cventry}[5][.25em]{}

% makes a resume entry with a proficiency comment
% usage: \cvitemwithcomment[spacing]{header}{text}{comment}
\newcommand*{\cvitemwithcomment}[4][.25em]{}

% makes a generic hyperlink
% usage: \link[optional text]{link}
\newcommand*{\link}[2][]{%
  \ifthenelse{\equal{#1}{}}%
    {\href{#2}{#2}}%
    {\href{#2}{#1}}}

% makes a http hyperlink
% usage: \httplink[optional text]{link}
\newcommand*{\httplink}[2][]{%
  \ifthenelse{\equal{#1}{}}%
    {\href{http://#2}{#2}}%
    {\href{http://#2}{#1}}}

% makes an email hyperlink
% usage: \emaillink[optional text]{link}
\newcommand*{\emaillink}[2][]{%
  \ifthenelse{\equal{#1}{}}%
    {\href{mailto:#2}{#2}}%
    {\href{mailto:#2}{#1}}}

% cvcolumns environment, where every column is created through \cvcolumn
% usage: \begin{cvcolumns}
%          \cvcolumn[width]{head}{content}
%          \cvcolumn[width]{head}{content}
%          ...
%        \end{cvcolumns}
% where "width" is the width as a fraction of the line length (between 0 and 1), "head" is the column header and "content" its content
\newcounter{cvcolumnscounter}% counter for the number of columns
\newcounter{cvcolumnsautowidthcounter}% counter for the number of columns with no column width provided, and which will then be equally distributed
\newcounter{tmpiteratorcounter}% counter for any temporary purpose (e.g., iterating loops)
\newlength{\cvcolumnsdummywidth}\setlength{\cvcolumnsdummywidth}{1000pt}% dummy width for total width, in order to enable arithmetics (TeX has no float variables, only integer counters or lengths)
\newlength{\cvcolumnswidth}% total width available for head / content
\newlength{\cvcolumnsautowidth}% total width of columns with no explicit width provided
\newlength{\cvcolumnautowidth}% width of one of the columns with no explicit width provided (based on equal distribution of remaining space)
\newif\if@cvcolumns@head@empty% whether or not at least one of the columns has a header
\newenvironment*{cvcolumns}%
  {% at environment opening: reset counters, lengths and ifs
    \setcounter{cvcolumnscounter}{0}%
    \setcounter{cvcolumnsautowidthcounter}{0}%
    \setlength{\cvcolumnsautowidth}{\cvcolumnsdummywidth}%
    \setlength{\cvcolumnautowidth}{0pt}%
    \@cvcolumns@head@emptytrue\ignorespaces}%
  {% at environment closing: typeset environment
    % compute the width of each cvcolumn, considering a spacing of \separatorcolumnwidth and the columns with set width
    \ifnum\thecvcolumnscounter>0%
      \setlength{\cvcolumnswidth}{\maincolumnwidth-\value{cvcolumnscounter}\separatorcolumnwidth+\separatorcolumnwidth}%
      \setlength{\cvcolumnautowidth}{\cvcolumnswidth*\ratio{\cvcolumnsautowidth}{\cvcolumnsdummywidth}/\value{cvcolumnsautowidthcounter}}\fi%
    % pre-aggregate the tabular definition, heading and content (required before creating the tabular, as the tabular environment doesn't like loops --- probably because "&" generates a \endgroup)
    % - the tabular definition is the aggregation of the different "\cvcolumn<i>@def" (by default "p{\cvcolumnautowidth}"), separated by "@{\hspace*{\separatorcolumnwidth}}"
    % - the tabular heading is the aggregation of the different "\cvcolumn<i>@head", separated by "&"
    % - the tabular content is the aggregation of the different "\cvcolumn<i>@content", separated by "&"
    % to aggregate the different elements, \protected@edef or \g@addto@macro is required to avoid that \cvcolumns@def, -@head and -@content get expanded in subsequent redefinitions, which would cause errors due to the expansions of \hspace, of \subsectionstyle and possibly of user content/argument such as font commands
    \def\cvcolumns@def{}%
    \def\cvcolumns@head{}%
    \def\cvcolumns@content{}%
    \setcounter{tmpiteratorcounter}{0}%
    % loop based on \g@addto@macro
    \loop\ifnum\thetmpiteratorcounter<\thecvcolumnscounter%
      \ifnum\thetmpiteratorcounter=0\else%
        \g@addto@macro\cvcolumns@def{@{\hspace*{\separatorcolumnwidth}}}%
        \g@addto@macro\cvcolumns@head{&}%
        \g@addto@macro\cvcolumns@content{&}\fi%
%      \expandafter\g@addto@macro\expandafter\cvcolumns@def\expandafter{\csname cvcolumn\roman{tmpiteratorcounter}@def\endcsname}%      % this creates issues with the colortbl" package (loaded by xcolor when passing the "table" option) as the column definitions passed to \begin{tabular} contains \cvcolumn<i>@def references that it doesn't understand; the next 2 lines expand \cvcolumn@def to the point it doesn't
      \edef\tmpcvcolumn@def{\csname cvcolumn\roman{tmpiteratorcounter}@def\endcsname}%
      \expandafter\g@addto@macro\expandafter\cvcolumns@def\expandafter{\tmpcvcolumn@def}%
      \expandafter\g@addto@macro\expandafter\cvcolumns@head\expandafter{\csname cvcolumn\roman{tmpiteratorcounter}@head\endcsname}%
      \expandafter\g@addto@macro\expandafter\cvcolumns@content\expandafter{\csname cvcolumn\roman{tmpiteratorcounter}@content\endcsname}%
      \stepcounter{tmpiteratorcounter}%
      \repeat%
      
    % create the tabular
    \cvitem{}{%
%      \begin{tabular}{\cvcolumns@def}% this conflicts with the "colortbl" package (loaded by xcolor when passing the "table" option), and requires the below 2 lines to expand \cvcolumns@def
      \def\begincvcolumns{\begin{tabular}[t]}% "[t]" is required for some body styles; the default alignment is "[c]"
      \expandafter\begincvcolumns\expandafter{\cvcolumns@def}%
        \if@cvcolumns@head@empty\else%
          \cvcolumns@head%\\[-.8em]%
%          {\color{color1}\rule{\maincolumnwidth}{.25pt}}%
          \\\fi%
        \cvcolumns@content%
      \end{tabular}}}

% cvcolumn command, to create a column inside a cvcolumns environment
% usage: \cvcolumn[width]{head}{content}
% where "width" is the width as a fraction of the line length (between 0 and 1), "head" is the column header and "content" its content ("head" and "content" can contain "\\", "\newline" or any other paragraph command such as "itemize")
\newcommand*{\cvcolumn}[3][\cvcolumnautowidth]{%
%  \def\cvcolumn@width{}%
  \ifthenelse{\equal{#1}{\cvcolumnautowidth}}%
    {% if no width fraction is provided, count this column as auto-adjusted and set its width to \cvcolumnsautowidth
      \stepcounter{cvcolumnsautowidthcounter}%
      \expandafter\expandafter\expandafter\def\expandafter\csname cvcolumn\roman{cvcolumnscounter}@def\endcsname{p{\cvcolumnautowidth}}%
      \expandafter\expandafter\expandafter\def\expandafter\csname cvcolumn\roman{cvcolumnscounter}@head\endcsname{\protect\parbox[b]{\cvcolumnautowidth}{\protect\subsectionstyle{#2}}}}%
    {% if a width is provided, set the width of the column to it and decrease the available space for auto-adjusted columns
      \addtolength{\cvcolumnsautowidth}{-#1\cvcolumnsdummywidth}%
      \expandafter\expandafter\expandafter\def\expandafter\csname cvcolumn\roman{cvcolumnscounter}@def\endcsname{p{#1\cvcolumnswidth}}%
      \expandafter\expandafter\expandafter\def\expandafter\csname cvcolumn\roman{cvcolumnscounter}@head\endcsname{\protect\parbox[b]{#1\cvcolumnswidth}{\protect\subsectionstyle{#2}}}}%
  \ifthenelse{\equal{#2}{}}{}{\@cvcolumns@head@emptyfalse}%
  \expandafter\expandafter\expandafter\def\expandafter\csname cvcolumn\roman{cvcolumnscounter}@content\endcsname{\protect\cvcolumncell{#3}}%
  \stepcounter{cvcolumnscounter}%
  \ignorespaces}

% internal cvcolumncell command, that enables a cvcolumn cell to contain paragraph commands (lists, newlines, etc)
\newcommand*{\cvcolumncell}[1]{{% put cell inside a group, so that command redefinitions are only local
  % roughly restore \\ to its regular definition (outside of tabular)
  \renewcommand*{\\}{\newline}%
  % enclose the contents of the cell inside a vertical box, to allow paragraph commands
  \protect\vtop{#1}}}

% itemize, enumerate and description environment
\setlength{\leftmargini}   {1em}
\leftmargin\leftmargini
\setlength{\leftmarginii}  {\leftmargini}
\setlength{\leftmarginiii} {\leftmargini}
\setlength{\leftmarginiv}  {\leftmargini}
\setlength{\leftmarginv}   {\leftmargini}
\setlength{\leftmarginvi}  {\leftmargini}
\setlength{\labelsep}      {.5em}% this is the distance between the label and the body, but it pushes the label to the left rather than pushing the body to the right (to do the latter, modify \leftmargin(i)
\setlength{\labelwidth}    {\leftmargini}% unfortunately, \labelwidth is not defined by item level (i.e. no \labeliwidth, \labeliiwidth, etc)
\addtolength{\labelwidth}  {-\labelsep}
\@beginparpenalty -\@lowpenalty
\@endparpenalty   -\@lowpenalty
\@itempenalty     -\@lowpenalty
\newcommand\labelenumi{\theenumi.}
\newcommand\labelenumii{(\theenumii)}
\newcommand\labelenumiii{\theenumiii.}
\newcommand\labelenumiv{\theenumiv.}
\renewcommand\p@enumii{\theenumi}
\renewcommand\p@enumiii{\p@enumii(\theenumii)}
\renewcommand\p@enumiv{\p@enumiii\theenumiii}
% description label
\newcommand*\descriptionlabel[1]{\hspace\labelsep\normalfont\bfseries#1}

\moderncvhead{}
\moderncvbody{}

\endinput
