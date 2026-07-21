$categories = @(
    @{ Name = "law";         Title = "Remote Law Jobs";         Heading = "Latest Remote Law Posts" },
    @{ Name = "medicine";    Title = "Remote Medicine Jobs";    Heading = "Latest Remote Medicine Posts" },
    @{ Name = "engineering"; Title = "Remote Engineering Jobs"; Heading = "Latest Remote Engineering Posts" },
    @{ Name = "data";        Title = "Remote Data Jobs";        Heading = "Latest Remote Data Posts" },
    @{ Name = "finance";     Title = "Remote Finance Jobs";     Heading = "Latest Remote Finance Posts" },
    @{ Name = "operations";  Title = "Remote Operations Jobs";  Heading = "Latest Remote Operations Posts" },
    @{ Name = "sciences";    Title = "Remote Science Jobs";     Heading = "Latest Remote Science Posts" },
    @{ Name = "creative";    Title = "Remote Creative Jobs";    Heading = "Latest Remote Creative Posts" },
    @{ Name = "language";    Title = "Remote Language Jobs";    Heading = "Latest Remote Language Posts" },
    @{ Name = "tech";        Title = "Remote Tech Jobs";        Heading = "Latest Remote Tech Posts" },
    @{ Name = "misc";        Title = "Remote Miscellaneous Jobs"; Heading = "Latest Remote Misc Posts" }
)

foreach ($cat in $categories) {
    $fileName = "$($cat.Name).html"

    $content = @"
---
layout: default
title: "$($cat.Title)"
---

<h1>📚 $($cat.Heading)</h1>

<ul>
  {% for post in site.categories.$($cat.Name) %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
"@

    Set-Content -Path $fileName -Value $content -Encoding UTF8
    Write-Host "Created $fileName"
}
