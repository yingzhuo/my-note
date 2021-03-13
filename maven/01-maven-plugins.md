## 常用maven插件

#### 01-ant

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <version>3.0.0</version>
    <executions>
        <execution>
            <id>post-pkg</id>
            <phase>package</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <target>
                    <copy todir="${project.build.directory}/docker-context/" force="true">
                        <fileset dir="${project.basedir}/src/docker">
                            <include name="**/*"/>
                        </fileset>
                        <fileset dir="${project.basedir}/target">
                            <include name="${project.build.finalName}.jar"/>
                        </fileset>
                    </copy>
                    <delete>
                        <fileset dir="${project.basedir}/target/">
                            <include name="*.jar*"/>
                        </fileset>
                    </delete>
                </target>
            </configuration>
        </execution>
    </executions>
</plugin>
```

#### 02-assembly

```xml
<!-- 打胖包 -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>3.3.0</version>
    <configuration>
        <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
        <appendAssemblyId>true</appendAssemblyId>
    </configuration>
    <executions>
        <execution>
            <id>make-assembly</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

```xml
<!-- 打zip包已备上线 -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>3.3.0</version>
    <configuration>
        <descriptors>
            <descriptor>${project.basedir}/src/main/assembly/bin.xml</descriptor>
        </descriptors>
        <appendAssemblyId>true</appendAssemblyId>
        <outputDirectory>${project.basedir}/../dist</outputDirectory>
    </configuration>
    <executions>
        <execution>
            <id>make-assembly</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<assembly xmlns="http://maven.apache.org/ASSEMBLY/2.1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/ASSEMBLY/2.1.0 http://maven.apache.org/xsd/assembly-2.1.0.xsd">

    <!-- bin.xml -->

    <id>bin</id>

    <formats>
        <format>tar.gz</format>
    </formats>

    <includeBaseDirectory>false</includeBaseDirectory>

    <fileSets>
        <fileSet>
            <directory>${project.basedir}/src/main/assembly</directory>
            <outputDirectory>bin</outputDirectory>
            <includes>
                <include>**/*.sh</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.basedir}/target</directory>
            <outputDirectory>jar</outputDirectory>
            <includes>
                <include>**/*.jar</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.basedir}/../.docker-compose</directory>
            <outputDirectory>dco</outputDirectory>
            <includes>
                <include>**/*.yml</include>
                <include>**/*.yaml</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.basedir}/../.k8s</directory>
            <outputDirectory>k8s</outputDirectory>
            <includes>
                <include>**/*.yml</include>
                <include>**/*.yaml</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.basedir}/../.paw</directory>
            <outputDirectory>paw</outputDirectory>
            <includes>
                <include>**/*.paw</include>
            </includes>
        </fileSet>
        <fileSet>
            <directory>${project.basedir}</directory>
            <includes>
                <include>README.*</include>
            </includes>
        </fileSet>
    </fileSets>

</assembly>
```