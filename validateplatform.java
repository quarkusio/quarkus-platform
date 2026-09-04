///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS info.picocli:picocli:4.5.0
//DEPS io.quarkus:quarkus-devtools-registry-client:2.2.0.CR1

//DESCRIPTION quick hack to validate platform descriptors
//DESCRIPTION Make sure platform have been built then run:
//DESCRIPTION if you have a file with list of dependences to check if supported or not run:
//DESCRIPTION ./validateplatform.java --deps service.deps `find generated-platform-project -name "*descriptor*.json"`
//DESCRIPTION to get a report of extensions where product is supported but extension in community non-stable
//DESCRIPTION ./validateplatform.java kafka.deps `find generated-platform-project -name "*descriptor*.json"`
//DESCRIPTION output is tab separated; I use visidata to easily browse it.

import io.quarkus.maven.ArtifactCoords;
import io.quarkus.registry.catalog.Extension;
import io.quarkus.registry.catalog.ExtensionCatalog;
import io.quarkus.registry.catalog.ExtensionOrigin;
import io.quarkus.registry.catalog.json.JsonCatalogMapperHelper;
import io.quarkus.registry.catalog.json.JsonCatalogMerger;
import io.quarkus.registry.catalog.json.JsonExtensionCatalog;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Parameters;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static java.util.stream.Collectors.toList;

@Command(name = "validateplatform", mixinStandardHelpOptions = true, version = "validateplatform 0.1",
        description = "validateplatform made with jbang")
class validateplatform implements Callable<Integer> {

    @Parameters(arity = "1..N", description = "the descriptors to read", defaultValue = "")
    private Set<String> descriptors;

    @CommandLine.Option(names = "--deps", description = "file with List of GAV/dependencies to validate against the platform")
    Path deps;

    public static void main(String... args) {
        int exitCode = new CommandLine(new validateplatform()).execute(args);
        System.exit(exitCode);
    }

    static class Validation {
        String kind;
        Extension ext;
        List<ExtensionOrigin> origins;

        public String getKind() {
            return kind;
        }

        public Validation(String missing_status, Extension ext, List<ExtensionOrigin> origins) {
            this.kind = missing_status;
            this.ext = ext;
            this.origins = origins;
        }

        @Override
        public String toString() {
            return  kind +
                    "\t" + ext.getArtifact().getGroupId() +
                    "\t" + ext.getArtifact().getArtifactId() +
                    "\t" + ext.getArtifact().getVersion() +
                    "\t" + ext.getMetadata().get("status") +
                    "\t" + ext.getMetadata().get("redhat-support") +
                    "\t" + origins;

        }
    }

    @Override
    public Integer call() throws Exception { // your business logic goes here...
        //  URI u = new URI("https://repo1.maven.org/maven2/io/quarkus/quarkus-universe-bom-quarkus-platform-descriptor/2.2.0.CR1/quarkus-universe-bom-quarkus-platform-descriptor-2.2.0.CR1-2.2.0.CR1.json");

        List<ExtensionCatalog> catalogs = new ArrayList<>();

        for (String path : descriptors) {
            JsonExtensionCatalog catalog = null;
            catalog = JsonCatalogMapperHelper.deserialize(Path.of(path), JsonExtensionCatalog.class);
            catalogs.add(catalog);
        }

        var mergedCatalog = JsonCatalogMerger.merge(catalogs);

        if(deps==null) {
            var validations = validate(mergedCatalog);
            validations.stream().forEach(System.out::println);
        } else{
            var dependencies = Files.readAllLines(deps).stream().filter(s -> !s.isBlank()).collect(toList());

            dependencies = dependencies.stream().distinct().collect(toList());

            Pattern p = Pattern.compile("^(?<groupid>[^:]*):(?<artifactid>[^:]*)(:(?<version>[^:@]*))?(:(?<classifier>[^@]*))?(@(?<type>.*))?$");

            System.out.println("dependency\tmatch in platform\tredhat-support\tstatus");
            for (String dep :
                    dependencies) {

                Matcher matcher = p.matcher(dep);

                var lists = List.of();
                if(matcher.find()) {
                    String g = matcher.group("groupid");
                    String a = matcher.group("artifactid");

                    var matchingExtensions = mergedCatalog.getExtensions().stream().filter(ext -> a.equals(ext.getArtifact().getArtifactId()) && g.equals(ext.getArtifact().getGroupId())).collect(toList());
                    if(matchingExtensions.isEmpty()) {
                        System.out.println(dep + "\tNO MATCH\tnot an extension ?");
                    } else {
                        System.out.println(dep + "\t " + matchingExtensions +
                                            "\t" + matchingExtensions.stream().findFirst().map(e ->
                                {
                                    var redhat = Optional.ofNullable(e.getMetadata().get("redhat-support"));
                                    var status = Optional.ofNullable(e.getMetadata().get("status"));
                                    return redhat.orElse("") + "\t" + status.orElse("stable?");
                                }
                                ).get());
                    }
                } else {
                    System.out.println("Could not recognize " + dep);
                }
            }
        }
        return 0;
    }

    private List<Validation> validate(ExtensionCatalog mergedCatalog) {
        List<Validation> validations = new ArrayList<>();
        var extensions = mergedCatalog.getExtensions();
        for (Extension ext : extensions) {
            var redhat = ext.getMetadata().get("redhat-support");
            var status = ext.getMetadata().get("status");

                if (redhat != null) {
                    // System.out.println(redhat + " <-> " + status);
                    if (redhat instanceof Collection) {
                        if (((Collection) redhat).contains("supported") && !(status == null || status.equals("stable"))) {
                            validations.add(new Validation("Product supported but not stable", ext, ext.getOrigins()));
                        }
                    }
                }
            }
        return validations;
    }
}
