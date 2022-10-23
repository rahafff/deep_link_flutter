import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_link_test/product_detail_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';



class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  // void initDynamicLinks() async{
  //   dynamicLinks.onLink.listen(
  //     onSuccess: (PendingDynamicLinkData? dynamicLink)async{
  //       final Uri deeplink = dynamicLink!.link;
  //
  //       if(deeplink != null){
  //         handleMyLink(deeplink);
  //       }
  //     },
  //     onError: (OnLinkErrorException e)async{
  //       print("We got error $e");
  //
  //     }
  //
  //   );
  // }
  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
      final Uri deeplink = dynamicLinkData.link;
            handleMyLink(deeplink);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }


  void handleMyLink(Uri url){
    List<String> sepeatedLink = [];
    /// osama.link.page/Hellow --> osama.link.page and Hellow
    sepeatedLink.addAll(url.path.split('/'));

    print("the token is ${sepeatedLink[1]}" );

    Get.to(()=>ProductDetailScreen(sepeatedLink[1]));

  }


  buildDynamicLinks(String title,String image,String docId) async {
    String url = "https://rahafdeep.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/$docId'),
      androidParameters: AndroidParameters(
        packageName: "com.example.deep_link_test",
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: "Bundle-ID",
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          description: '',
          imageUrl:
          Uri.parse("$image"),
          title: title),
    );

    // final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();


    final ShortDynamicLink shortLink =
    await dynamicLinks.buildShortLink(parameters);


    String? desc = shortLink.shortUrl.toString();

    print('Short lint to share  ${desc}');
    // await Share.share(desc, subject: title,);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading:  Icon(Icons.menu,color: Colors.black,),
        centerTitle: true,
        title: Text("Ayyan Shop",style: TextStyle(color: Colors.black),),
        actions: [
          Icon(Icons.input,color: Colors.black,),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(

          child: Column(
            children: [


              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  children: const [
                    Text("Popular Ads",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),

                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('ads').snapshots(),
                  builder: (ctx,snapshot){

                    if(!snapshot.hasData){
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }


                    List<DocumentSnapshot> ads = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: ads.length,

                      itemBuilder: (ctx,index){


                        String title = '',image = '',price='';

                        try{
                          title = ads[index].get('title');
                        }catch(e){
                          title = '';
                        }

                        try{
                          image = ads[index].get('image');
                        }catch(e){
                          image = '';
                        }

                        try{
                          price = ads[index].get('price');
                        }catch(e){
                          price = '';
                        }

                        return Column(
                          children: [
                            InkWell(
                              onTap: (){
                                Get.to(()=> ProductDetailScreen(ads[index].id));
                              },
                              child: Container(
                                width: Get.width,
                                height: Get.width*0.5,
                                child: Image.network(image,fit: BoxFit.cover,),
                              ),
                            ),
                            Text(title,style: TextStyle(fontWeight: FontWeight.bold),),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Price: \$$price",style: TextStyle(fontWeight: FontWeight.bold),),
                                IconButton(onPressed: (){
                                  buildDynamicLinks(title, image, ads[index].id);
                                }, icon: Icon(Icons.share)),
                              ],
                            ),



                          ],
                        );

                      },);
                  },
                ),
              ),

            ],
          )
      ),
    ));
  }
}


