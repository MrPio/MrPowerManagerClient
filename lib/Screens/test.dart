import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              stretch: true,
              expandedHeight: 200,
              backgroundColor: Colors.amber,
              floating: false,
              pinned: true,
              toolbarHeight: 40,

            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              title: Text("roooooooooo",style: GoogleFonts.lato(fontSize: 34),),
            ),),
          ];
        },
        body: Column(
          children: [
            Text(
              'dddddddd',
              style: GoogleFonts.lato(fontSize: 50),
            ),
            Text(
              'dddddddd',
              style: GoogleFonts.lato(fontSize: 50),
            ),
            Text(
              'dddddddd',
              style: GoogleFonts.lato(fontSize: 50),
            ),
            Text(
              'dddddddd',
              style: GoogleFonts.lato(fontSize: 50),
            ),
            Text(
              'dddddddd',
              style: GoogleFonts.lato(fontSize: 50),
            ),
          ],
        ),
      ),
    );
  }
}
