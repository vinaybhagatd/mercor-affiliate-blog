@echo off
echo Creating Mercor category pages...

:: LAW
echo --- > law.html
echo layout: default >> law.html
echo title: "Remote Law Jobs" >> law.html
echo --- >> law.html
echo ^<h1^>📚 Latest Remote Law Posts^</h1^> >> law.html
echo ^<ul^> >> law.html
echo {% for post in site.categories.law %} >> law.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> law.html
echo {% endfor %} >> law.html
echo ^</ul^> >> law.html

:: MEDICINE
echo --- > medicine.html
echo layout: default >> medicine.html
echo title: "Remote Medicine Jobs" >> medicine.html
echo --- >> medicine.html
echo ^<h1^>📚 Latest Remote Medicine Posts^</h1^> >> medicine.html
echo ^<ul^> >> medicine.html
echo {% for post in site.categories.medicine %} >> medicine.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> medicine.html
echo {% endfor %} >> medicine.html
echo ^</ul^> >> medicine.html

:: ENGINEERING
echo --- > engineering.html
echo layout: default >> engineering.html
echo title: "Remote Engineering Jobs" >> engineering.html
echo --- >> engineering.html
echo ^<h1^>📚 Latest Remote Engineering Posts^</h1^> >> engineering.html
echo ^<ul^> >> engineering.html
echo {% for post in site.categories.engineering %} >> engineering.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> engineering.html
echo {% endfor %} >> engineering.html
echo ^</ul^> >> engineering.html

:: DATA
echo --- > data.html
echo layout: default >> data.html
echo title: "Remote Data Jobs" >> data.html
echo --- >> data.html
echo ^<h1^>📚 Latest Remote Data Posts^</h1^> >> data.html
echo ^<ul^> >> data.html
echo {% for post in site.categories.data %} >> data.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> data.html
echo {% endfor %} >> data.html
echo ^</ul^> >> data.html

:: FINANCE
echo --- > finance.html
echo layout: default >> finance.html
echo title: "Remote Finance Jobs" >> finance.html
echo --- >> finance.html
echo ^<h1^>📚 Latest Remote Finance Posts^</h1^> >> finance.html
echo ^<ul^> >> finance.html
echo {% for post in site.categories.finance %} >> finance.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> finance.html
echo {% endfor %} >> finance.html
echo ^</ul^> >> finance.html

:: OPERATIONS
echo --- > operations.html
echo layout: default >> operations.html
echo title: "Remote Operations Jobs" >> operations.html
echo --- >> operations.html
echo ^<h1^>📚 Latest Remote Operations Posts^</h1^> >> operations.html
echo ^<ul^> >> operations.html
echo {% for post in site.categories.operations %} >> operations.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> operations.html
echo {% endfor %} >> operations.html
echo ^</ul^> >> operations.html

:: SCIENCES
echo --- > sciences.html
echo layout: default >> sciences.html
echo title: "Remote Science Jobs" >> sciences.html
echo --- >> sciences.html
echo ^<h1^>📚 Latest Remote Science Posts^</h1^> >> sciences.html
echo ^<ul^> >> sciences.html
echo {% for post in site.categories.sciences %} >> sciences.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> sciences.html
echo {% endfor %} >> sciences.html
echo ^</ul^> >> sciences.html

:: CREATIVE
echo --- > creative.html
echo layout: default >> creative.html
echo title: "Remote Creative Jobs" >> creative.html
echo --- >> creative.html
echo ^<h1^>📚 Latest Remote Creative Posts^</h1^> >> creative.html
echo ^<ul^> >> creative.html
echo {% for post in site.categories.creative %} >> creative.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> creative.html
echo {% endfor %} >> creative.html
echo ^</ul^> >> creative.html

:: LANGUAGE
echo --- > language.html
echo layout: default >> language.html
echo title: "Remote Language Jobs" >> language.html
echo --- >> language.html
echo ^<h1^>📚 Latest Remote Language Posts^</h1^> >> language.html
echo ^<ul^> >> language.html
echo {% for post in site.categories.language %} >> language.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> language.html
echo {% endfor %} >> language.html
echo ^</ul^> >> language.html

:: TECH
echo --- > tech.html
echo layout: default >> tech.html
echo title: "Remote Tech Jobs" >> tech.html
echo --- >> tech.html
echo ^<h1^>📚 Latest Remote Tech Posts^</h1^> >> tech.html
echo ^<ul^> >> tech.html
echo {% for post in site.categories.tech %} >> tech.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> tech.html
echo {% endfor %} >> tech.html
echo ^</ul^> >> tech.html

:: MISC
echo --- > misc.html
echo layout: default >> misc.html
echo title: "Remote Miscellaneous Jobs" >> misc.html
echo --- >> misc.html
echo ^<h1^>📚 Latest Remote Misc Posts^</h1^> >> misc.html
echo ^<ul^> >> misc.html
echo {% for post in site.categories.misc %} >> misc.html
echo   ^<li^>^<a href="{{ post.url }}"^>{{ post.title }}^</a^>^</li^> >> misc.html
echo {% endfor %} >> misc.html
echo ^</ul^> >> misc.html

echo All category pages created successfully.
