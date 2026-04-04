---
title: ""
---

```{=latex}
% Romanos desde o início (rótulos PDF + \thepage coerentes). Sem isto, a página
% após a capa herda fancy + arábico até o \cleardoublepage seguinte.
\pagenumbering{roman}
\setcounter{page}{1}

% Capa (PDF): opcional — adicione assets/epub-cover.png para capa full bleed.
\thispagestyle{empty}
\newgeometry{margin=0pt}
\IfFileExists{assets/epub-cover.png}{%
\noindent\includegraphics[width=\paperwidth,height=\paperheight,keepaspectratio=false]{assets/epub-cover.png}%
}{%
\vspace*{\fill}
\begin{center}
{\LARGE\bfseries Masmorra ASCII}\\[0.75em]
{\large\itshape Aprenda Dart construindo um roguelike no terminal}
\end{center}
\vspace*{\fill}%
}
\restoregeometry
\clearpage

% Folha de Rosto (PDF Only)
\cleardoublepage
\thispagestyle{empty}

\begin{center}
\vspace*{3cm}

{\Huge \bfseries Masmorra ASCII}

\vspace{1em}

{\Large Aprenda Dart construindo um roguelike no terminal}

\vspace{4cm}

{\Large \textbf{Kleber de Oliveira Andrade}}

\vfill

\textbf{Clube de Autores} \\
2026

\end{center}

\newpage

% Página de Copyright (PDF) — créditos como book-17; sem ficha catalográfica (CIP)
\thispagestyle{empty}

\vspace*{1em}

\begin{center}
\small
\textbf{Edição e texto:} Kleber de Oliveira Andrade  \\
\textbf{Revisão:} Kleber de Oliveira Andrade \\
\textbf{Capa | Ilustração:} Nano Banana AI \\
\textbf{Capa | Fechamento:} Nano Banana AI \\
\textbf{Diagramação:} Kleber de Oliveira Andrade \\
\textbf{Ilustrações Internas:} Nano Banana AI
\end{center}

\vspace*{\fill}

\vspace*{\fill}

\small
\noindent Copyright: 2026 Kleber de Oliveira Andrade

\vspace{1em}

\footnotesize
\noindent Todos os direitos reservados. É proibida a reprodução, total ou parcial, desta obra sem autorização prévia do autor.

\vspace{0.5em}

\noindent Obra de natureza técnica. Exemplos de código e excertos são educativos; nomes de produtos ou marcas citados pertencem aos respectivos titulares.

\vspace{1em}

\noindent ISBN: 978-65-00-XXXXX-X

\vspace{1em}

\begin{center}
Clube de Autores
\end{center}
\clearpage

% Numeração romana até o sumário; arábica a partir da Parte I (definida em parte-1).
```

```{=html}
<div class="epub-title-page">
  <p class="main-title">Masmorra ASCII</p>
  <p class="subtitle">Aprenda Dart construindo um roguelike no terminal</p>
  <p class="author"><strong>Kleber de Oliveira Andrade</strong></p>
  <div class="publisher-info">
    <p><strong>Clube de Autores</strong><br/>2026</p>
  </div>
</div>

<div class="page-break"></div>

<div class="epub-copyright-page">
  <div class="credits">
    <p><strong>Edição e texto:</strong> Kleber de Oliveira Andrade</p>
    <p><strong>Revisão:</strong> Kleber de Oliveira Andrade</p>
    <p><strong>Capa | Ilustração:</strong> Nano Banana AI</p>
    <p><strong>Capa | Fechamento:</strong> Nano Banana AI</p>
    <p><strong>Diagramação:</strong> Kleber de Oliveira Andrade</p>
    <p><strong>Ilustrações Internas:</strong> Nano Banana AI</p>
  </div>

  <div class="legal-text">
    <p>Copyright: 2026 Kleber de Oliveira Andrade</p>
    <p class="disclaimer-caps">Todos os direitos reservados. É proibida a reprodução, total ou parcial, desta obra sem autorização prévia do autor.</p>
    <p class="disclaimer-caps">Obra de natureza técnica. Exemplos de código e excertos são educativos; nomes de produtos ou marcas citados pertencem aos respectivos titulares.</p>

    <p>ISBN: 978-65-00-XXXXX-X</p>

    <p class="rights-reserved">TODOS OS DIREITOS DESTA EDIÇÃO RESERVADOS AO AUTOR.</p>

    <p style="text-align: center;">Clube de Autores</p>
  </div>
</div>

<div class="page-break"></div>
```
