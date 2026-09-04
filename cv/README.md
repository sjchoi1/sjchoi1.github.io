# Curriculum Vitae

The editable LaTeX source is `CV_sangjinchoi.tex`. The generated PDF is published at `output/pdf/CV_sangjinchoi.pdf` and is linked from the homepage.

From the repository root, build the PDF with:

```powershell
.\cv\build.cmd
```

The launcher runs `build.ps1` without changing the machine-wide PowerShell execution policy. The build closes a dedicated PDF viewer displaying this CV, runs `pdflatex` twice so page references are resolved, keeps intermediate files in `cv/build/`, and updates the public PDF only after a successful build. It also retries temporary OneDrive sharing locks before failing with an actionable message.
