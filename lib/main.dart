import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink(
    'https://eu-central-1-shared-euc1-02.cdn.hygraph.com/content/clv6lwqu7000001w690st4vix/master', // Replace with your GraphQL endpoint
  );

  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: httpLink,
    ),
  );
  runApp(MyApp(
    client: client,
  ));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MyApp({super.key, required this.client});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String readUsers = """
  query GetUsers {
   products{
    name
    price
    categories {
      name
      
    }
    updatedAt
    createdAt
  }
  }
""";

//    String addUserMutation = """
//   mutation AddUser(\$name: String!, \$email: String!) {
//     addUser(name: \$name, email: \$email) {
//       id
//       name
//       email
//     }
//   }
// """;

//   void addUser(String name, String email) {
//     final MutationOptions options = MutationOptions(
//       document: gql(addUserMutation),
//       variables: {
//         'name': name,
//         'email': email,
//       },
//     );

//     client.value.mutate(options).then((result) {
//       if (result.hasException) {
//         print('Error: ${result.exception}');
//       } else {
//         print('User added: ${result.data}');
//       }
//     });
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Query(
            options: QueryOptions(
              document: gql(readUsers), // Use the query string
            ),
            builder: (QueryResult result,
                {Refetch? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (result.hasException) {
                return Center(
                    child: Text('Error: ${result.exception.toString()}'));
              }

              // Parse the data
              List users = result.data!['products'];

              return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['price'].toString()),
                    );
                  });
            }));
  }
}
