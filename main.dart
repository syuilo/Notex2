import "notex2.dart";

void main() {
	var note = new Notex2("""
#Notex2
*Notex2* is Misskey note compiler.

#abc
ho*geho*ge
##Xxxx
###Aaaaaa
###Bbbbbb
###Ccccccc
##Yyy
aaa

#afadf
asdda
##asfd
dgsfgdgh

end

#test
##list
foo
-Abc
-Def
-Ghi
bar

##link
click[here](http://syuilo.com).

""");
	
	Article a = note.compile();
	String html = a.toHtml();
	print(html);
}