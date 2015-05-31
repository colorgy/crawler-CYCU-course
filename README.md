中原課程爬蟲
==========

超神的，因為網頁前端用 angular 接 API，所以就直接拿來用了，不愧是中原。

# EXAMPLE

## `GET`

```
http://itouch.cycu.edu.tw/active_system/CourseQuerySystem/GetCourses.jsp?yearTerm=1031
```

然後抓下來解析，先 split `@` 再 split `|`，看一下他們網頁的解析方式對照著存資料。
