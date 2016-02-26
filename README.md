# Takahē
Takahē is a set of files which allows a web developer to put together a client-side XSLT site with all navigation in an external XML file. This site is both documentation of how to use Takahē, and a demonstration of what it can do.

[Full documentation of Takahē](http://labs.realise.com/rossa/takahe/) is available.

Takahē expects to sit in the root of a web server and assumes that the web server will serve index.xml files as default, inside directories. It will probably work if the file extension of the files is .html, but I've not tried this.

## IIS

index.xml can be made the default file in IIS like this:

![Select your site from the left-hand pane, then in the centre pane, under the IIS heading, click on Default Document](http://i.imgur.com/mwnRHkl.png)

![In the Actions pane on the right-hand-side, click on Add](http://i.imgur.com/UfNRREY.png)

![An Add Default Document alert box should appear. Type in index.xml into it.](http://i.imgur.com/sQrxzoW.png)

![If this has been done correctly, index.xml should appear in the list of default documents, in the centre pane.](http://i.imgur.com/QYINXRd.png)
