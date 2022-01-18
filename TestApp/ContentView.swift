/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPAssurance
import AEPCore
import AEPEdgeConsent
import AEPPlaces
import AEPUserProfile
import CoreLocation
import SwiftUI

let HEADING_FONT_SIZE: CGFloat = 25.0

struct ContentView: View {
    var body: some View {
        ScrollView(.vertical) {
            AssuranceCard()
            AnalyticsCard()
            UserProfileCard()
            ConsentCard()
            PlacesCard()

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct YellowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.foregroundColor(.black)
            Spacer()
        }
        .padding()
        .background(Color.yellow.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct AssuranceCard: View {
    @State private var assuranceURL: String = ""
    var body: some View {
        VStack {
            HStack {

                Text("Assurance: v" + Assurance.extensionVersion)
                    .padding(.leading)
                    .font(.system(size: HEADING_FONT_SIZE, weight: .heavy, design: .default))
                Spacer()
            }

            HStack {
                TextField("Copy Assurance Session URL to here", text: $assuranceURL)
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .frame(height: 100)
                    .frame(height: 50)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }

            HStack {
                Button(action: {
                    if let url = URL(string: self.assuranceURL) {
                        Assurance.startSession(url: url)
                    }
                }, label: {
                    Text("Connect")
                }).buttonStyle(YellowButtonStyle()).padding()
            }
        }
    }
}

struct UserProfileCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("UserProfile").padding(.leading).font(.system(size: HEADING_FONT_SIZE, weight: .heavy, design: .default))
                Spacer()
            }

            HStack {
                Button(action: {
                    let userProfile: [String: Any] = [
                        "type": "HardCore Gamer",
                        "age": 16
                    ]
                    UserProfile.updateUserAttributes(attributeDict: userProfile)
                }, label: {
                    Text("Update")
                }).buttonStyle(YellowButtonStyle()).padding()

                Button(action: {
                    UserProfile.removeUserAttributes(attributeNames: ["type"])
                }, label: {
                    Text("Remove ")
                }).buttonStyle(YellowButtonStyle()).padding()
            }
        }
    }
}

struct AnalyticsCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("Analytics").padding(.leading).font(.system(size: HEADING_FONT_SIZE, weight: .heavy, design: .default))
                Spacer()
            }
            HStack {
                Button(action: {
                   //MobileCore.dispatch(event: Event(name: "Event 1", type: "type", source: "source", data: nil))
                   MobileCore.dispatch(event: Event(name: "Event 2", type: "type", source: "source", data: BIG_DATA))
//                   MobileCore.dispatch(event: Event(name: "Event 3", type: "type", source: "source", data: nil))
//                   MobileCore.dispatch(event: Event(name: "Event 4", type: "type", source: "source", data: nil))
//                   MobileCore.dispatch(event: Event(name: "Event 5", type: "type", source: "source", data: nil))
//                   MobileCore.dispatch(event: Event(name: "Event 6", type: "type", source: "source", data: nil))
                }, label: {
                    Text("Track Action")
                }).buttonStyle(YellowButtonStyle()).padding()

                Button(action: {
                    MobileCore.track(state: "Home Page", data: nil)
                }, label: {
                    Text("Track State")
                }).buttonStyle(YellowButtonStyle()).padding()
            }
        }
    }
}

struct ConsentCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("Consent").padding(.leading).font(.system(size: HEADING_FONT_SIZE, weight: .heavy, design: .default))
                Spacer()
            }

            HStack {
                Button(action: {
                    let collectConsent = ["collect": ["val": "y"]]
                    let currentConsents = ["consents": collectConsent]
                    Consent.update(with: currentConsents)
                }, label: {
                    Text("Consent Yes")
                }).buttonStyle(YellowButtonStyle()).padding()

                Button(action: {
                    let collectConsent = ["collect": ["val": "n"]]
                    let currentConsents = ["consents": collectConsent]
                    Consent.update(with: currentConsents)
                }, label: {
                    Text("Consent No")
                }).buttonStyle(YellowButtonStyle()).padding()
            }
        }
    }
}

struct PlacesCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("Places").padding(.leading).font(.system(size: HEADING_FONT_SIZE, weight: .heavy, design: .default))
                Spacer()
            }

            HStack {
                Button(action: {
                    let location = CLLocation(latitude: 37.335480, longitude: -121.893028)
                    Places.getNearbyPointsOfInterest(forLocation: location, withLimit: 10) { nearbyPois, responseCode in
                        print("responseCode: \(responseCode.rawValue) \nnearbyPois: \(nearbyPois)")
                    }
                }, label: {
                    Text("Get POIs")
                }).buttonStyle(YellowButtonStyle())

                Button(action: {
                    let regionCenter = CLLocationCoordinate2D(latitude: 37.3255196, longitude: -121.9458237)
                    let region = CLCircularRegion(center: regionCenter, radius: 100, identifier: "dfb81b5a-1027-431a-917d-41292916d575")
                    Places.processRegionEvent(PlacesRegionEvent.entry, forRegion: region)
                }, label: {
                    Text("Entry")
                }).buttonStyle(YellowButtonStyle())

                Button(action: {
                    let regionCenter = CLLocationCoordinate2D(latitude: 37.3255196, longitude: -121.9458237)
                    let region = CLCircularRegion(center: regionCenter, radius: 100, identifier: "dfb81b5a-1027-431a-917d-41292916d575")
                    Places.processRegionEvent(PlacesRegionEvent.exit, forRegion: region)
                }, label: {
                    Text("Exit")
                }).buttonStyle(YellowButtonStyle())
            }
        }
    }
}
let BIG_DATA: Dictionary = ["one": "Lorem ipsum dolor sit amet. Sit obcaecati maiores eos assumenda consequuntur aut itaque ullam aut voluptas quas eos adipisci dolores et voluptatibus dicta. Sit nisi quos eos voluptatem culpa cum assumenda accusantium cum voluptatem quasi non consequuntur voluptatem est necessitatibus iusto et sint sapiente. Nam voluptatem internos qui consequatur aperiam et voluptatem eaque non quae repudiandae et alias eveniet. Est natus repellat ad nostrum autem aut saepe corporis ea iure blanditiis fugit facilis vel nisi architecto et aliquid reprehenderit. Vel nihil reprehenderit hic velit omnis aut temporibus non quisquam earum qui dolores alias sit doloribus voluptas! Sed molestiae dicta ab suscipit numquam non aliquam alias est sint voluptas qui odio molestiae et iure dignissimos. Aut laudantium tempora aut iste tempore ut nulla beatae a repellat enim in quas necessitatibus aut sint ratione. Non cumque saepe ut modi galisum est mollitia possimus est iusto vitae! Non dolor repudiandae ea aspernatur quam in voluptatum blanditiis qui dolorem repellendus et omnis itaque sit aperiam quis. Et rerum placeat et aspernatur aspernatur et Quis totam et possimus illo. Et galisum dolore eos nisi cumque et rerum architecto omnis enim sed voluptatem porro sed facilis cumque et labore magni. Aut libero architecto hic debitis aliquid aut nisi ducimus est delectus architecto aut vero nesciunt. Est temporibus fuga in consequuntur odio in neque porro in unde laborum ut nulla quia ex dolores iusto aut dolorem recusandae. Ut illum quod rem omnis quidem ex corrupti sapiente qui enim atque! Ab iure fugiat aut ullam voluptate et culpa debitis ut provident ea similique numquam. Aut voluptatem voluptas sed rerum nemo qui laudantium velit qui tenetur nihil.Et quia accusamus qui deserunt porro est quia omnis At expedita velit qui odit quia quo quam eveniet est autem nesciunt. In animi aliquid et enim enim sit sapiente dolores qui nulla consequatur qui eveniet asperiores. Sit consequatur voluptatem et assumenda galisum ut molestiae galisum a dolor illum eum odio rerum. Eum repellendus voluptatem eos quisquam pariatur aut facilis recusandae sit rerum sint aut dolorum galisum. Non beatae quis ut sunt vitae qui mollitia quia ut perferendis saepe. Qui iusto commodi ut voluptatem dolorem et facere voluptate sed consectetur fugit non omnis earum. Et labore suscipit aut Quis ipsum in consectetur doloribus sed quaerat quaerat eum accusantium neque et assumenda dolores. Non praesentium sequi in debitis mollitia ea dolorem cumque hic possimus rerum. Aut suscipit natus et necessitatibus nemo ut velit expedita non minima quaerat. Et voluptate eveniet aut beatae laudantium eos ipsam aliquam sit Quis distinctio aut tempora sint. Aut culpa fugiat aut mollitia reprehenderit non adipisci eaque eos sint molestias sed natus consequatur et beatae omnis qui recusandae omnis. Sed labore itaque ea impedit velit est placeat distinctio et dolores sint aut accusamus consectetur et dolores Quis ipsum dolor. Aut necessitatibus architecto et neque recusandae qui quisquam dignissimos quo veritatis tempore? Est omnis harum sed voluptas inventore et saepe consectetur. Tempore tempora est eligendi modi est reprehenderit aspernatur. Est fuga animi et quia amet nam nemo blanditiis non aperiam incidunt eum obcaecati possimus. Vel totam nihil aut doloribus voluptas vel consectetur numquam qui aliquam voluptate! Et dicta doloremque et nihil vero eum sint corrupti est dolore doloremque quo aliquam nihil? Ex enim debitis qui assumenda suscipit et illo veritatis rem molestias omnis est eligendi accusantium ad iusto nulla sit voluptas consequatur. Est enim voluptas rem ullam tempore aut cumque eaque? Qui nostrum molestiae nam voluptate excepturi est cumque voluptatem non nesciunt porro in magni maiores. Et doloremque quaerat eum quidem ducimus id ducimus porro sit accusamus architecto aut velit deleniti. 33 distinctio unde sed vitae ipsa ex ullam rerum ad delectus omnis est possimus pariatur? In omnis nemo quo inventore officia non explicabo voluptatem et molestiae deleniti ea laborum omnis 33 neque pariatur et voluptatem autem. A similique impedit et eaque blanditiis qui perspiciatis ipsam et minima accusantium ut debitis nesciunt. Est maiores nihil non saepe repellendus sed doloribus aperiam ex accusantium animi reiciendis nobis et voluptas corporis ut voluptatem accusantium! Nam laborum deserunt ut porro galisum eos ipsum maiores ut delectus quae. Ab voluptates reiciendis in fugiat accusamus est eius veniam aut sint illum. Nihil quis et mollitia quae hic perferendis numquam ab cumque excepturi et molestias explicabo a commodi deserunt. Id fuga omnis et delectus possimus nam architecto omnis et dolore eligendi in iste voluptatibus non soluta! In fact, inserting any fantasy text or a famous text, be it a poem, a speech, a literary passage, a song's text, etc., our text generator will provide the random extraction of terms and steps to compose your own exclusive Lorem Ipsum.Many of the order confirmation alerts you send via email get lost in the flood of messages customers receive daily. If you really want your customers to see your confirmation messages, consider texting them. Here are a few text message templates you can use. SMS marketing is an excellent customer service tool because messages are delivered and read almost immediately — and there’s room for two-way communication. And SMS customer service can be scaled and automated. Plus, if you leverage this channel, your business will save money on phone service and customer service personnel training. See a few templates for customer support messages below. There aren’t many nice ways to remind people to pay up, and plenty of not-so-nice ways of doing it. When sending payment reminders, aim for a tone that conveys a sense of urgency without sounding harsh. Plus, you should provide clear instructions to make the payment process smooth. Below are a few examples that illustrate friendly payment reminders: The authors is giving a classification of civilisations depending on the degree of colonisation of the Earth, Solar System and Our Galaxy. The problems of: History of geographic discoveries (The great geographical discoveries during the Middle Age, the concurence of Chinnese and Europeans in this Area); The Astrophysics, such as: Asteroids, Water and Atmosphere on outer planets, Planet Mars Planet, Agriculture on outer planets, Minerals on outer planets; Cosmic flights: Fuels, Robotics, Moon (as an intermediary basis for interplanetary flights), Mars colonisation; Interstellar flights, Space research costs, strategy and tactics of the space colonisation; Policy: War and Peace, International Collaboration are discussed. This article reviews research concerning interpersonal distance as a function of interpersonal relationships, attraction, and reactions to spatial invasion. To integrate research findings, we propose a simple model, based on the idea that people seek an optimal distance from others that becomes smaller with friends and larger for individuals who do not expect to interact. The model describes comfort-discomfort as a function of interaction distance in three situations: interacting friends, interacting strangers, and strangers who do not expect interaction. These three personal space profiles are discussed in terms of qualifying variables, such as seated vs. standing interaction, sex composition of the dyad, intimacy of conversation topics, and situational variables. The design of a three-axis search coil magnetometer in the 1 Hz–20 kHz range developed for the scientific satellite DEMETER is described. The sensitivity is a critical parameter as the search coil must be able to detect very weak signals in the Earth’s magnetosphere. The sensitivity is mainly constrained by the size and the mass allocated onboard the spacecraft. Significant improvements are made in terms of mass and sensitivity over previous space-borne search coils. We achieve a noise level of 4fTHz−1∕2 at 6 kHz and a mass of 430𝑔 for the three search coils and the bracket. A good agreement is observed on the estimation by finite element analysis of the sensor impedance and the measurements. The gain and noise model of the search coil and its preamplifier also agree quite well with measurements.Humans have always looked at the heavens and wondered about the nature of the objects seen in the night sky. With the development of rockets and the advances in electronics and other technologies in the 20th century, it became possible to send machines and animals and then people above Earth’s atmosphere into outer space. Well before technology made these achievements possible, however, space exploration had already captured the minds of many people, not only aircraft pilots and scientists but also writers and artists. The strong hold that space travel has always had on the imagination may well explain why professional astronauts and laypeople alike consent at their great peril, in the words of Tom Wolfe in The Right Stuff (1979), to sit “on top of an enormous Roman candle, such as a Redstone, Atlas, Titan or Saturn rocket, and wait for someone to light the fuse.” It perhaps also explains why space exploration has been a common and enduring theme in literature and art. As centuries of speculative fiction in books and more recently in films make clear, “one small step for [a] man, one giant leap for mankind” was taken by the human spirit many times and in many ways before Neil Armstrong stamped humankind’s first footprint on the Moon. Although the possibility of exploring space has long excited people in many walks of life, for most of the latter 20th century and into the early 21st century, only national governments could afford the very high costs of launching people and machines into space. This reality meant that space exploration had to serve very broad interests, and it indeed has done so in a variety of ways. Government space programs have increased knowledge, served as indicators of national prestige and power, enhanced national security and military strength, and provided significant benefits to the general public. In areas where the private sector could profit from activities in space, most notably the use of satellites as telecommunication relays, commercial space activity has flourished without government funding. In the early 21st century, entrepreneurs believed that there were several other areas of commercial potential in space, most notably privately funded space travel.In the years after World War II, governments assumed a leading role in the support of research that increased fundamental knowledge about nature, a role that earlier had been played by universities, private foundations, and other nongovernmental supporters. This change came for two reasons. First, the need for complex equipment to carry out many scientific experiments and for the large teams of researchers to use that equipment led to costs that only governments could afford. Second, governments were willing to take on this responsibility because of the belief that fundamental research would produce new knowledge essential to the health, the security, and the quality of life of their citizens. Thus, when scientists sought government support for early space experiments, it was forthcoming. Since the start of space efforts in the United States, the Soviet Union, and Europe, national governments have given high priority to the support of science done in and from space. From modest beginnings, space science has expanded under government support to include multibillion-dollar exploratory missions in the solar system. Examples of such efforts include the development of the Curiosity Mars rover, the Cassini-Huygens mission to Saturn and its moons, and the development of major space-based astronomical observatories such as the Hubble Space Telescope.It perhaps also explains why space exploration has been a common and enduring theme in literature and art. As centuries of speculative fiction in books and more recently in films make clear, “one small step for [a] man, one giant leap for mankind” was taken by the human spirit many times and in many ways before Neil Armstrong stamped humankind’s first footprint on the Moon. Although the possibility of exploring space has long excited people in many walks of life, for most of the latter 20th century and into the early 21st century, only national governments could afford the very high costs of launching people and machines into space. This reality meant that space exploration had to serve very broad interests, and it indeed has done so in a variety of ways. Government space programs have increased knowledge, served as indicators of national prestige and power, enhanced national security and military strength, and provided significant benefits to the general public. In areas where the private sector could profit from activities in space, most notably the use of satellites as telecommunication relays, commercial space activity has flourished without government funding. In the early 21st century, entrepreneurs believed that there were several other areas of commercial potential in space, most notably privately funded space travel.In the years after World War II, governments assumed a leading role in the support of research that increased fundamental knowledge about nature, a role that earlier had been played by universities, private foundations, and other nongovernmental supporters. This change came for two reasons. First, the need for complex equipment to carry out many scientific experiments and for the large teams of researchers to use that equipment led to costs that only governments could afford. Second, governments were willing to take on this responsibility because of the belief that fundamental research would produce new knowledge essential to the health, the security, and the quality of life of their citizens. Thus, when scientists sought government support for early space experiments, it was forthcoming. Since the start of space efforts in the United States, the Soviet Union, and Europe, national governments have given high priority to the support of science done in and from space. From modest beginnings, space science has expanded under government support to include multibillion-dollar exploratory missions in the solar system. Examples of such efforts include the development of the Curiosity Mars rover, the Cassini-Huygens mission to Saturn and its moons, and the development of major space-based astronomical observatories such as the Hubble Space Telescope.It perhaps also explains why space exploration has been a common and enduring theme in literature and art. As centuries of speculative fiction in books and more recently in films make clear, “one small step for [a] man, one giant leap for mankind” was taken by the human spirit many times and in many ways before Neil Armstrong stamped humankind’s first footprint on the Moon. Although the possibility of exploring space has long excited people in many walks of life, for most of the latter 20th century and into the early 21st century, only national governments could afford the very high costs of launching people and machines into space. This reality meant that space exploration had to serve very broad interests, and it indeed has done so in a variety of ways. Government space programs have increased knowledge, served as indicators of national prestige and power, enhanced national security and military strength, and provided significant benefits to the general public. In areas where the private sector could profit from activities in space, most notably the use of satellites as telecommunication relays, commercial space activity has flourished without government funding. In the early 21st century, entrepreneurs believed that there were several other areas of commercial potential in space, most notably privately funded space travel.In the years after World War II, governments assumed a leading role in the support of research that increased fundamental knowledge about nature, a role that earlier had been played by universities, private foundations, and other nongovernmental supporters. This change came for two reasons. First, the need for complex equipment to carry out many scientific experiments and for the large teams of researchers to use that equipment led to costs that only governments could afford. Second, governments were willing to take on this responsibility because of the belief that fundamental research would produce new knowledge essential to the health, the security, and the quality of life of their citizens. Thus, when scientists sought government support for early space experiments, it was forthcoming. Since the start of space efforts in the United States, the Soviet Union, and Europe, national governments have given high priority to the support of science done in and from space. From modest beginnings, space science has expanded under government support to include multibillion-dollar exploratory missions in the solar system. Examples of such efforts include the development of the Curiosity Mars rover, the Cassini-Huygens mission to Saturn and its moons, and the development of major space-based astronomical observatories such as the Hubble Space Telescope."]

